module Admin
  class BookingsController < BaseController
    before_action :set_booking, only: [:show, :update, :destroy, :edit]

    def index
      @bookings = Booking.includes(:user, :tickets, :start_stop, :end_stop)
        .search(params[:search])
        .filter_by_status(params[:payment_status])
        .filter_by_date_range(params[:start_date], params[:end_date])
        .order(created_at: :desc)

      @total_bookings = @bookings.size
      @pagy, @bookings = pagy(@bookings)

      respond_to do |format|
        format.html
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'bookings_table',
            partial: 'admin/bookings/shared/bookings',
            locals: { bookings: @bookings }
          )
        end
      end
    end

    def show; end

    def edit; end

    def update
      if @booking.update(payment_status: Booking::PaymentStatus::COMPLETED)
        @booking.tickets.update_all(status: Ticket::Status::PAID) # rubocop:disable Rails/SkipsModelValidations
        handle_success(t('.success'))
      else
        handle_failure(t('.failure'))
      end
    end

    def destroy # rubocop:disable Metrics/AbcSize
      if @booking.pending? || @booking.completed?
        refund_payment(@booking) if @booking.stripe_session_id.present?

        # Lưu các dữ liệu cần thiết trước khi xóa
        booking_data = {
          id: @booking.id,
          user_id: @booking.user_id,
          start_stop: { location: { name: @booking.start_stop.location.name } },
          end_stop: { location: { name: @booking.end_stop.location.name } },
          tickets: @booking.tickets.map do |ticket|
            {
              departure_date: ticket.departure_date,
              departure_time: ticket.departure_time,
              formatted_departure_date: ticket.formatted_departure_date,
              formatted_departure_time: ticket.formatted_departure_time
            }
          end
        }

        if @booking.tickets.any?
          schedule = @booking.tickets.first.schedule
        end
        user = @booking.user

        @booking.destroy

        # Truyền dữ liệu đã lưu vào notification
        CancelBookingCableNotifier.with(booking: booking_data, schedule: schedule).deliver(user)
        CancelBookingNotifier.with(booking: booking_data, schedule: schedule).deliver(user)

        handle_success(t('.success'))
      else
        handle_failure(t('.failure'))
      end
    end

    private

    def set_booking
      @booking = Booking.find(params[:id])
    end

    def booking_params
      params.permit(:payment_status, :start_date, :end_date)
    end

    def refund_payment(booking)
      session = Stripe::Checkout::Session.retrieve(booking.stripe_session_id)
      if session.payment_status == 'paid'
        payment_intent = session.payment_intent
        Stripe::Refund.create(payment_intent: payment_intent)
      end
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe refund error: #{e.message}"
    end

    def handle_success(message)
      flash[:success] = message
      respond_to do |format|
        format.html { redirect_to admin_bookings_path }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            'toast_flash',
            partial: 'layouts/flash',
            locals: { type: 'success', message: message }
          )
        end
      end
    end

    def handle_failure(message)
      flash[:error] = message
      respond_to do |format|
        format.html { redirect_back fallback_location: admin_bookings_path }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            'toast_flash',
            partial: 'layouts/flash',
            locals: { type: 'alert', message: message }
          )
        end
      end
    end
  end
end
