class LocationsController < ApplicationController
  def search
    query = params[:query]
    locations = Location.where('name ILIKE ?', "%#{query}%").limit(10)

    render json: locations.map { |location| { id: location.id, name: location.name } }
  rescue StandardError => e
    # Capture the exception in Sentry
    Sentry.capture_exception(e)
  end
end
