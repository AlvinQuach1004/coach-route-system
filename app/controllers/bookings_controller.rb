# app/controllers/bookings_controller.rb
class BookingsController < ApplicationController
  before_action :check_user_signed_in, only: :create
  before_action :set_schedule, only: [:create]
  before_action :set_stops, only: [:create]

  def create
    @booking = current_user.bookings.build(booking_params)
    authorize @booking
    @booking.payment_status = 'pending'
    @booking.payment_method = 'cash'
    ActiveRecord::Base.transaction do
      if @booking.save
        create_tickets
        redirect_to invoice_booking_path(@booking)
      else
        redirect_back(fallback_location: route_pages_path)
        raise ActiveRecord::Rollback, 'Failed to save booking'
      end
    end
  rescue ActiveRecord::RecordInvalid, StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def invoice
    @booking = current_user.bookings.find(params[:id])
  end

  def thank_you; end

  private

  def booking_params
    params.require(:booking).permit(
      :payment_method,
      :payment_status,
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
    selected_seats = JSON.parse(params[:booking][:selected_seats])
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
end
