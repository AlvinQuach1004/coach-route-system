class BookingsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :check_user_signed_in_booking
  before_action :set_schedule, only: [:create]
  before_action :set_stops, only: [:create]
  before_action :check_booking_limit, only: [:create]
  before_action :set_booking, only: [:invoice]

  def create
    @booking = current_user.bookings.build(booking_params)
    authorize @booking
    @booking.pending!
    @booking.online!

    ActiveRecord::Base.transaction do
      @booking.save!
      create_tickets

      session = create_stripe_session(@booking)
      @booking.update!(stripe_session_id: session.id)

      render json: { session_id: session.id }
      raise ActiveRecord::Rollback if @booking.blank?
    end
  rescue ActiveRecord::RecordInvalid, StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def invoice # rubocop:disable Metrics/PerceivedComplexity
    if @booking&.stripe_session_id.present?
      session = Stripe::Checkout::Session.retrieve(@booking.stripe_session_id)

      if session.payment_status == 'paid'
        ActiveRecord::Base.transaction do
          @booking.completed!
          @booking.tickets.map(&:paid!)
          raise ActiveRecord::Rollback, t('route_pages.bookings.errors.payment_failed') if @booking.tickets.any? { |ticket| !ticket.paid? }
        end
      else
        @booking.failed!
        @booking.tickets.map(&:cancelled!)
        redirect_to error_payment_bookings_path, alert: t('route_pages.bookings.errors.payment_failed')
      end
    else
      redirect_to root_path, alert: t('route_pages.bookings.errors.invalid_booking')
    end
  end

  def cancel
    @booking&.destroy if @booking&.pending?
    redirect_to root_path, alert: t('route_pages.bookings.success.cancelled')
  end

  private

  def check_user_signed_in_booking
    unless user_signed_in?
      respond_to do |format|
        format.json do
          render json: { error: t('route_pages.bookings.errors.not_logged_in') }, status: :unprocessable_entity
        end
      end
    end
  end

  def booking_params
    params.require(:booking).permit(:start_stop_id, :end_stop_id)
  end

  def set_schedule
    @schedule = Schedule.find(params[:schedule_id])
  end

  def check_booking_limit
    if booking_limit_reached?
      respond_to do |format|
        format.json do
          render json: { error: t('route_pages.bookings.errors.limit_reached') }, status: :unprocessable_entity
        end
      end
    end
  end

  def booking_limit_reached?
    current_user.bookings.where(created_at: Time.zone.now.beginning_of_day..).count >= 3
  end

  def set_stops
    @departure_stop = if params[:departure_search].present?
                        @schedule.route.stops.find_by(location_id: params[:departure_search], is_pickup: true)
                      end
    @destination_stop = if params[:destination_search].present?
                          @schedule.route.stops.find_by(location_id: params[:destination_search], is_dropoff: true)
                        end
  end

  def set_booking
    @booking = current_user.bookings.find_by(id: params[:id])
  end

  def create_tickets # rubocop:disable Metrics/AbcSize
    selected_seats = JSON.parse(params[:booking][:selected_seats])
    selected_seats.each do |seat_number|
      @booking.tickets.create!(
        schedule_id: @schedule.id,
        seat_number: seat_number,
        status: Ticket::Status::BOOKED,
        paid_amount: params[:booking][:ticket_price].present? ? params[:booking][:ticket_price].to_f : @schedule.price,
        pick_up: params[:booking][:pickup_address].presence || @booking.start_stop.address,
        drop_off: params[:booking][:dropoff_address].presence || @booking.end_stop.address,
        departure_date: params[:booking][:departure_date],
        departure_time: params[:booking][:departure_time]
      )
    end
  end

  def create_stripe_session(booking)
    Stripe::Checkout::Session.create(
      {
        payment_method_types: ['card'],
        line_items: build_line_items(booking),
        mode: 'payment',
        success_url: invoice_booking_url(booking),
        cancel_url: cancel_booking_url(booking),
        client_reference_id: booking.id.to_s,
        customer_email: current_user.email
      }
    )
  end

  def build_line_items(_booking) # rubocop:disable Metrics/AbcSize
    selected_seats = JSON.parse(params[:booking][:selected_seats])
    start_location = Stop.find(params[:booking][:start_stop_id])
    end_location = Stop.find(params[:booking][:end_stop_id])
    Rails.logger.info (params[:booking][:start_stop_id]).to_s
    selected_seats.map do |seat_number|
      {
        price_data: {
          currency: 'vnd',
          unit_amount: params[:booking][:ticket_price].present? ? params[:booking][:ticket_price].to_i : @schedule.price.to_i,
          product_data: {
            name: t('route_pages.bookings.stripe.product_name', booking_id: @booking.id),
            description: t(
              'route_pages.bookings.stripe.product_description',
              seat: seat_number,
              route: "#{start_location.location.name} - #{end_location.location.name}",
              coach: @schedule.coach.coach_type,
            )
          }
        },
        quantity: 1
      }
    end
  end
end
