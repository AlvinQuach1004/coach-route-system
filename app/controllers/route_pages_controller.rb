class RoutePagesController < ApplicationController
  before_action :retrieve_keywords, only: :index
  def index
    @booking = Booking.new
    @schedules = Schedule.includes(:coach, :route).all

    # Apply filters
    apply_filters

    @total_schedules = @schedules.size
    # Pagination
    @pagy, @schedules = pagy(@schedules)
    if params[:departure].present?
      @departure_search = Location.find_by('LOWER(name) = ?', params[:departure].downcase)
    end
    if params[:destination].present?
      @destination_search = Location.find_by('LOWER(name) = ?', params[:destination].downcase)
    end

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

  def booking_params
    params.require(:booking).permit(
      :start_stop_id,
      :end_stop_id,
      :payment_method,
      :payment_status
    )
  end

  def apply_filters
    apply_category_filter
    apply_keywords_filter
    apply_trends_filter
    apply_search
    apply_sort_by_price
    apply_price_range
  end

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
      mapped_category = category_mapping[params[:category]] || params[:category]
      if mapped_category
        @schedules = @schedules.joins(:coach).where(coaches: { coach_type: mapped_category.downcase })
      end
    end
  end

  # Filter by keywords (e.g., locations in the route)
  def apply_keywords_filter
    if params[:keywords].present?
      # Fetch all location names from params and find their corresponding IDs in a single query
      location_names = params[:keywords].flat_map { |keyword| keyword.split('_') }.uniq
      locations = Location.where(name: location_names).pluck(:id, :name).to_h { |id, name| [name, id] }

      query_conditions = []

      params[:keywords].each do |keyword|
        start_location_name, end_location_name = keyword.split('_')

        start_location_id = locations[start_location_name]
        end_location_id = locations[end_location_name]

        next if start_location_id.nil? || end_location_id.nil?

        query_conditions << @schedules.joins(:route).where(
          routes: { start_location_id: start_location_id, end_location_id: end_location_id }
        )
      end

      # Combine all the query conditions with OR if there are any valid ones
      if query_conditions.any?
        @schedules = query_conditions.reduce(:or)
      end
    end
  end

  # Filter by trends
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
    filter_by_departure if params[:departure].present?
    filter_by_destination if params[:destination].present?
    filter_by_date if params[:date].present?
  end

  def filter_by_departure
    departure_location = find_location(params[:departure])
    return unless departure_location

    route_ids_for_departure = Stop.where(location_id: departure_location.id, is_pickup: true).pluck(:route_id)
    @schedules = @schedules.joins(:route).where(route_id: route_ids_for_departure)
  end

  def filter_by_destination
    destination_location = find_location(params[:destination])
    return unless destination_location

    route_ids_for_destination = Stop.where(location_id: destination_location.id, is_dropoff: true).pluck(:route_id)
    @schedules = @schedules.joins(:route)
      .where(route_id: route_ids_for_destination)
      .where(route_id: @schedules.select(:route_id))
  end

  def filter_by_date
    date = parse_date(params[:date])
    @schedules = @schedules.where(departure_date: date) if date
  end

  def find_location(location_name)
    Location.find_by('LOWER(name) = ?', location_name.downcase)
  end

  def parse_date(date_string)
    Date.parse(date_string)
  rescue StandardError
    nil
  end

  def apply_price_range
    max_price = params[:price].to_i if params[:price].present?
    @schedules = @schedules.where(price: ..max_price) if max_price
  end

  def apply_sort_by_price
    if params[:sort_by].present?
      sort_by = params[:sort_by]
      if sort_by.include?('price_high_to_low')
        @schedules = @schedules.order('price DESC')
      elsif sort_by.include?('price_low_to_high')
        @schedules = @schedules.order('price ASC')
      else
        @schedules
      end
    end
  end
end
