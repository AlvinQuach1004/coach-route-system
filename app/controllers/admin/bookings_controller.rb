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
      if @booking.update(payment_status: 'completed')
        @booking.tickets.update_all(status: 'paid') # rubocop:disable Rails/SkipsModelValidations
        flash[:success] = 'Payment status updated successfully.'
        redirect_to admin_booking_path(@booking)
      else
        flash[:error] = 'Failed to update payment status.'
        render :edit
      end
    end

    def destroy
      @booking.user.notifications.destroy
      @booking.destroy
      flash[:success] = 'Booking cancelled successfully.'
      redirect_to admin_bookings_path
    end

    private

    def set_booking
      @booking = Booking.find(params[:id])
    end

    def booking_params
      params.permit(:payment_status, :start_date, :end_date)
    end
  end
end
