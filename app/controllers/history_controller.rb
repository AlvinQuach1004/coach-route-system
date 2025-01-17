class HistoryController < ApplicationController
  before_action :check_user_signed_in, only: [:index]
  def index
    authorize Booking
    @bookings =
      current_user.bookings
        .includes(
          :tickets,
          :start_stop,
          :end_stop,
          tickets: { schedule: :coach }
        )
        .order(created_at: :desc)
    @total_bookings = @bookings.count
    @pagy, @bookings = pagy(@bookings)
  end
end
