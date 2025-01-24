# app/controllers/route_pages_controller.rb
class RoutePagesController < ApplicationController
  before_action :retrieve_keywords, only: :index

  def index
    @booking = Booking.new
    query = RoutePagesQuery.new(params)
    @schedules = query.result
    @total_schedules = query.count

    @pagy, @schedules = pagy(@schedules)

    @departure_search = find_location(params[:departure]) if params[:departure].present?
    @destination_search = find_location(params[:destination]) if params[:destination].present?

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          'schedules',
          partial: 'route_pages/shared/route_card',
          locals: { schedules: @schedules, booking: @booking, departure_search: @departure_search, destination_search: @destination_search }
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
