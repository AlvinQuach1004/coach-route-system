class RoutePagesController < ApplicationController
  before_action :retrieve_keywords, only: :index

  def index # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    Rails.logger.debug { "Keywords params: #{params[:keywords].inspect}" }
    @booking = Booking.new

    query = RoutePagesQuery.new(
      scope: Schedule.includes(route: :stops),
      params: params
    ).call

    @schedules = query[:schedules]
    @total_schedules = query[:total]
    @schedules_without_routes = Schedule.all
    @stops_with_location = @schedules_without_routes.map do |schedule|
      Stop.joins(:location)
        .where(route_id: schedule.route_id)
        .select('stops.*, locations.name AS location_name')
        .map do |stop|
        {
          id: stop.id,
          route: stop.route_id,
          address: stop.address,
          latitude: stop.latitude_address,
          longitude: stop.longitude_address,
          province: stop.location_name,
          pickup: stop.is_pickup,
          dropoff: stop.is_dropoff,
          departure_date: schedule.formatted_departure_date,
          departure_time: schedule.formatted_departure_time,
          stop_order: stop.stop_order
        }
      end
    end.flatten

    @pagy, @schedules = pagy(@schedules)

    @departure_search = find_location(params[:departure]) if params[:departure].present?
    @destination_search = find_location(params[:destination]) if params[:destination].present?

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          'schedules',
          partial: 'route_pages/shared/route_card',
          locals: {
            schedules: @schedules,
            booking: @booking,
            departure_search: @departure_search,
            destination_search: @destination_search,
            stops_with_location: @stops_with_location
          }
        )
      end
    end
  end

  private

  def retrieve_keywords
    @keywords = Schedule
      .joins(route: [:start_location, :end_location])
      .select(
        'locations.name AS start_location_name,
        end_locations_routes.name AS end_location_name,
        COUNT(schedules.id) AS route_count'
      )
      .group('locations.name, end_locations_routes.name')
      .order('route_count DESC')
      .limit(3)
  end

  def find_location(location_name)
    Location.find_by('LOWER(name) = ?', location_name.downcase)
  end
end
