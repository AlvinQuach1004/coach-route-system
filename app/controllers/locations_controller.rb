class LocationsController < ApplicationController
  def search
    query = params[:query]
    locations = Location.where('name ILIKE ?', "%#{query}%").limit(10)

    render json: locations.map { |location| { id: location.id, name: location.name } }
  end
end
