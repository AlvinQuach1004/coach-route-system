class PaymentsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :check_user_signed_in, only: [:create]
  before_action :set_booking
  before_action :set_schedule, only: [:create]
  before_action :set_stops, only: [:create]

  def create
    @booking = current_user.bookings.build(booking_params)
    authorize @booking, :create?
    @booking.payment_status = 'pending'
    @booking.payment_method = 'stripe'
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

  def cancel
    @booking&.destroy if @booking&.payment_status == 'pending'
    redirect_to root_path, alert: 'Payment was cancelled.'
  end

  private

  def create_stripe_session(booking)
    Stripe::Checkout::Session.create(
      {
        payment_method_types: ['card'],
        line_items: build_line_items(booking),
        mode: 'payment',
        success_url: invoice_booking_url(booking),
        cancel_url: cancel_payment_url(booking),
        client_reference_id: @booking.id.to_s,
        customer_email: current_user.email
      }
    )
  end

  def build_line_items(_booking)
    selected_seats = JSON.parse(params[:selected_seats])
    @schedule.departure_time.strftime('%I:%M %p, %b %d')
    selected_seats.map do |seat_number|
      {
        price_data: {
          currency: 'vnd',
          unit_amount: @schedule.price.to_i,
          product_data: {
            name: "Ticket Booking ##{@booking.id}",
            description: "Seat: #{seat_number}, Route: #{@booking.start_stop.address} - #{@booking.end_stop.address}"
          }
        },
        quantity: 1
      }
    end
  end

  def booking_params
    params.require(:booking).permit(
      :start_stop_id,
      :end_stop_id
    )
  end

  def set_schedule
    @schedule = Schedule.find(params[:schedule_id])
  end

  def set_stops
    @departure_stop = if params[:departure_search].present?
                        @schedule.route.stops.find_by(
                          location_id: params[:departure_search],
                          is_pickup: true
                        )
                      end

    @destination_stop = if params[:destination_search].present?
                          @schedule.route.stops.find_by(
                            location_id: params[:destination_search],
                            is_dropoff: true
                          )
                        end
  end

  def create_tickets
    selected_seats = JSON.parse(params[:selected_seats])
    selected_seats.each do |seat_number|
      @booking.tickets.create!(
        schedule_id: @schedule.id,
        seat_number: seat_number,
        status: 'booked',
        paid_amount: @schedule.price,
        pick_up: @booking.start_stop.address,
        drop_off: @booking.end_stop.address
      )
    end
  end

  def set_booking
    @booking = current_user.bookings.find_by(id: params[:id])
  end
end
