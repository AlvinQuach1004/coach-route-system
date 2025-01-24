class RoutePagesQuery < ApplicationQuery
  def initialize(params)
    super()
    @params = params
    @relation = Schedule.includes(:coach, route: [:start_location, :end_location])
  end

  def result
    filter_by_category
    filter_by_keywords
    filter_by_trends
    filter_by_search
    filter_by_price_range
    sort_by_price
    @relation
  end

  def count
    result.size
  end

  private

  def filter_by_category
    category_mapping = {
      'Giường nằm' => 'sleeper',
      'Giường phòng' => 'room',
      'Limousine giường nằm' => 'limousine'
    }

    if @params[:category].present?
      mapped_category = category_mapping[@params[:category]] || @params[:category]
      @relation = @relation.joins(:coach).where(coaches: { coach_type: mapped_category.downcase }) if mapped_category
    end
  end

  def filter_by_keywords
    return if @params[:keywords].blank?

    location_names = @params[:keywords].flat_map { |keyword| keyword.split('_') }.uniq
    locations = Location.where(name: location_names).pluck(:id, :name).to_h { |id, name| [name, id] }

    query_conditions = @params[:keywords].filter_map do |keyword|
      start_name, end_name = keyword.split('_')
      start_id = locations[start_name]
      end_id = locations[end_name]
      next if start_id.nil? || end_id.nil?

      @relation.joins(:route).where(routes: { start_location_id: start_id, end_location_id: end_id })
    end

    @relation = query_conditions.reduce(:or) if query_conditions.any?
  end

  def filter_by_trends
    return if @params[:trends].blank?

    @relation = @relation.order(departure_date: :desc) if @params[:trends].include?('Latest')
  end

  def filter_by_search
    filter_by_departure if @params[:departure].present?
    filter_by_destination if @params[:destination].present?
    filter_by_date if @params[:date].present?
  end

  def filter_by_departure
    departure = find_location(@params[:departure])
    return unless departure

    route_ids = Stop.where(location_id: departure.id, is_pickup: true).pluck(:route_id)
    @relation = @relation.joins(:route).where(route_id: route_ids)
  end

  def filter_by_destination
    destination = find_location(@params[:destination])
    return unless destination

    route_ids = Stop.where(location_id: destination.id, is_dropoff: true).pluck(:route_id)
    @relation = @relation.joins(:route).where(route_id: route_ids)
  end

  def filter_by_date
    date = parse_date(@params[:date])
    @relation = @relation.where(departure_date: date) if date
  end

  def filter_by_price_range
    return if @params[:price].blank?

    max_price = @params[:price].to_i
    @relation = @relation.where(price: ..max_price)
  end

  def sort_by_price
    return if @params[:sort_by].blank?

    case @params[:sort_by]
    when 'price_high_to_low'
      @relation = @relation.order(price: :desc)
    when 'price_low_to_high'
      @relation = @relation.order(price: :asc)
    end
  end

  def find_location(location_name)
    Location.find_by('LOWER(name) = ?', location_name.downcase)
  end

  def parse_date(date_string)
    Date.parse(date_string)
  rescue StandardError
    nil
  end
end
