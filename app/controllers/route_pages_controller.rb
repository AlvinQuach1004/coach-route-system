class RoutePagesController < ApplicationController
  before_action :retrieve_keywords, only: :index
  def index
    @schedules = Schedule.includes(:coach, :route).all

    # Apply filters
    apply_category_filter
    apply_keywords_filter
    apply_trends_filter
    apply_search

    @total_schedules = @schedules.size
    # Pagination
    @pagy, @schedules = pagy(@schedules)
    respond_to do |format|
      format.html { render :index }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('schedules', partial: 'route_pages/shared/route_card', locals: { schedules: @schedules })
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

  # Filter by coach_type
  def apply_category_filter
    category_mapping = {
      'Giường nằm' => 'sleeper',
      'Giường phòng' => 'room',
      'Limousine giường nằm' => 'limousine'
    }

    if params[:category].present?
      mapped_category = category_mapping[params[:category]]
      if mapped_category
        @schedules = @schedules.joins(:coach).where(coaches: { coach_type: mapped_category })
      end
    end
  end

  # Filter by keywords (e.g., locations in the route)
  def apply_keywords_filter
    if params[:keywords].present?
      keywords = params[:keywords]
      @schedules = @schedules.joins(:route).where(
        'routes.start_location_id IN (:keywords) OR routes.end_location_id IN (:keywords)',
        keywords: Location.where(name: keywords).select(:id)
      )
    end
  end

  def apply_trends_filter
    if params[:trends].present?
      trends = params[:trends]
      if trends.include?('Latest')
        @schedules = @schedules.order(departure_date: :desc)
      end
    end
  end

  # Apply search for departure point, destination point and date
  def apply_search
    if params[:departure].present?
      departure_location = Location.find_by('LOWER(name) = ?', params[:departure].downcase)
      if departure_location
        @schedules = @schedules.joins(route: :start_location).where(routes: { start_location_id: departure_location.id })
      end
    end

    # Filter by destination location
    if params[:destination].present?
      destination_location = Location.find_by('LOWER(name) = ?', params[:destination].downcase)
      if destination_location
        @schedules = @schedules.joins(route: :end_location).where(routes: { end_location_id: destination_location.id })
      end
    end

    # Filter by departure date
    if params[:date].present?
      date = begin
        Date.parse(params[:date])
      rescue StandardError
        nil
      end
      @schedules = @schedules.where(departure_date: date) if date
    end
  end
end
