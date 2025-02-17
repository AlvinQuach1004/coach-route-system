class HomeController < ApplicationController
  layout 'application'

  def index
    start_of_week = Time.zone.today.beginning_of_week
    end_of_week = Time.zone.today.end_of_week

    # Top routes of the week
    @top_routes_of_week = Schedule
      .joins(route: [:start_location, :end_location])
      .where(departure_date: start_of_week..end_of_week)
      .select(
        'routes.id',
        'locations.name as start_location_name',
        'end_locations_routes.name as end_location_name',
        'COUNT(schedules.id) as route_count'
      )
      .group('routes.id, locations.name, end_locations_routes.name')
      .order('route_count DESC')
      .limit(3)

    @most_popular_routes = Schedule
      .joins(route: [:start_location, :end_location])
      .select(
        'routes.id',
        'locations.name as start_location_name',
        'end_locations_routes.name as end_location_name',
        'COUNT(schedules.id) as route_count'
      )
      .group('routes.id, locations.name, end_locations_routes.name')
      .order('route_count DESC')
      .limit(8)
  end
end
