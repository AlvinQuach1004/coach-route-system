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
    respond_to do |format|
      format.html { render :index }
      format.turbo_stream do
        if @schedules.any?
          render turbo_stream: turbo_stream.replace('schedules', partial: 'route_pages/shared/route_card', locals: { schedules: @schedules, booking: @booking })
        else
          render turbo_stream: turbo_stream.replace('schedules', partial: 'route_pages/shared/error_not_found')
        end
      end
    end
  end

  def create_booking
    @booking = Booking.new(booking_params)
    if current_user.nil?
      flash[:alert] = 'You must log in before booking.'
      return redirect_to new_user_session_path
    end
    @booking.user_id = current_user.id
    if @booking.save
      redirect_to route_pages_path, notice: 'Booking was successfully created.'
    else
      flash[:alert] = 'Failed to create booking.'
      render :index
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

      # Initialize an empty array to store query conditions
      query_conditions = []

      # Loop through each keyword and build the query conditions
      params[:keywords].each do |keyword|
        start_location_name, end_location_name = keyword.split('_')

        # Retrieve start and end location IDs from the preloaded hash
        start_location_id = locations[start_location_name]
        end_location_id = locations[end_location_name]

        # Only proceed if both locations are valid
        next if start_location_id.nil? || end_location_id.nil?

        # Build and store the query condition for this keyword
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
