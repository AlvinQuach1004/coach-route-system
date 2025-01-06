class RoutePagesController < ApplicationController
  def index
    @routes = Route.all

    if params[:departure].present?
      location = Location.find_by('LOWER(name) = ?', params[:departure].downcase)
      @routes = @routes.where(start_location: location.id) if location
    end

    if params[:destination].present?
      location = Location.find_by('LOWER(name) = ?', params[:destination].downcase)
      @routes = @routes.where(end_location: location.id) if location
    end

    if params[:date].present?
      date = Date.parse(params[:date])
      @routes = @routes.where(date: date)
    end
    @pagy, @routes = pagy(@routes)
  end
end
