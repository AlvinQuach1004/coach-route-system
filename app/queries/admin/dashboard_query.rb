module Admin
  class DashboardQuery < ApplicationQuery
    def initialize(scope:, params: {}) # rubocop:disable Lint/MissingSuper
      @scope = scope
      @params = params
    end

    def call
      {
        revenue_data: generate_revenue_data,
        bookings_by_route: generate_bookings_by_route,
        coach_status_amount: generate_coach_status_amount,
        recent_bookings: generate_recent_bookings,
        daily_stats: generate_daily_stats
      }
    end

    private

    def generate_revenue_data
      @scope.joins(:tickets)
        .where('bookings.created_at >= ? AND bookings.payment_status = ?', 30.days.ago, Booking::PaymentStatus::COMPLETED)
        .group_by_day('bookings.created_at')
        .sum('tickets.paid_amount')
    end

    def generate_bookings_by_route
      Route.joins(schedules: :tickets)
        .joins('INNER JOIN locations start_loc ON routes.start_location_id = start_loc.id')
        .joins('INNER JOIN locations end_loc ON routes.end_location_id = end_loc.id')
        .group('routes.id, start_loc.name, end_loc.name')
        .select('routes.id,
               start_loc.name as start_location_name,
               end_loc.name as end_location_name,
               COUNT(tickets.id) as ticket_count')
        .order('ticket_count DESC')
        .limit(5)
    end

    def generate_coach_status_amount
      Coach.group(:status).count
    end

    def generate_recent_bookings
      @scope.includes(:user, tickets: { schedule: { route: [:start_location, :end_location] } })
        .order(created_at: :desc)
        .limit(5)
    end

    def generate_daily_stats
      {
        active_routes: Schedule.where(status: Schedule::Status::SCHEDULED)
          .where(departure_date: Time.zone.today)
          .distinct
          .count('route_id'),

        todays_bookings: @scope.joins(:tickets)
          .where(created_at: Time.zone.now.all_day)
          .distinct
          .count,

        available_coaches: Coach.where(status: Coach::Status::AVAILABLE).count
      }
    end
  end
end
