module Admin
  class DashboardController < BaseController
    def index
      query = DashboardQuery.new(scope: Booking.all, params: params)
      result = query.call
      @revenue_data = result[:revenue_data]
      @bookings_by_route = result[:bookings_by_route]
      @coach_status_amount = result[:coach_status_amount]
      @recent_bookings = result[:recent_bookings]
      @daily_stats = result[:daily_stats]
    end
  end
end
