class RoutePagesQuery < ApplicationQuery
  def initialize(scope:, params: {}) # rubocop:disable Lint/MissingSuper
    @scope = scope
    @params = params
  end

  def call
    {
      total: @scope.size,
      schedules: filtered_scope
    }
  end

  private

  def filtered_scope
    @scope
      .extending(Scopes)
      .filter_by_category(@params[:category])
      .filter_by_keywords(@params[:keywords])
      .filter_by_trends(@params[:trends])
      .filter_by_departure(@params[:departure])
      .filter_by_destination(@params[:destination])
      .filter_by_date(@params[:date])
      .filter_by_price(@params[:price])
      .sort_by_price(@params[:sort_by])
  end

  module Scopes
    def filter_by_category(category)
      return self if category.blank?

      category_mapping = {
        'Giường nằm' => Coach::Capacity::SLEEPER,
        'Giường phòng' => Coach::Capacity::ROOM,
        'Limousine giường nằm' => Coach::Capacity::LIMOUSINE
      }

      mapped_category = category_mapping[category] || category
      joins(:coach).where(coaches: { coach_type: mapped_category.downcase })
    end

    def filter_by_keywords(keywords)
      return self if keywords.blank?

      location_names = keywords.flat_map { |keyword| keyword.split('_') }.uniq
      locations = Location.where(name: location_names).pluck(:id, :name).to_h { |id, name| [name, id] }

      query_conditions = keywords.filter_map do |keyword|
        start_location_name, end_location_name = keyword.split('_')
        start_location_id = locations[start_location_name]
        end_location_id = locations[end_location_name]
        next if start_location_id.nil? || end_location_id.nil?

        joins(:route).where(
          routes: { start_location_id: start_location_id, end_location_id: end_location_id }
        )
      end

      query_conditions.any? ? query_conditions.reduce(:or) : self
    end

    def filter_by_trends(trends)
      return self if trends.blank?
      return order(departure_date: :desc) if trends.include?('Latest')

      if trends.include?('Seat available')
        joins(:coach)
          .joins('LEFT JOIN tickets ON tickets.schedule_id = schedules.id')
          .select('schedules.*, coaches.capacity, COUNT(DISTINCT tickets.id) as booked_seats')
          .group('schedules.id, coaches.id, routes.id')
          .having('COUNT(DISTINCT tickets.id) < coaches.capacity')
      end
    end

    def filter_by_departure(departure)
      return self if departure.blank?

      departure_location = Location.find_by('LOWER(name) = ?', departure.downcase)

      departure_stops = Stop.where(is_pickup: true)
        .where('LOWER(address) ILIKE ?', "%#{departure.downcase}%")
        .or(Stop.where(location_id: departure_location&.id, is_pickup: true))

      route_ids = departure_stops.pluck(:route_id)

      joins(route: :stops)
        .where(routes: { id: route_ids })
        .or(joins(route: :stops).where(stops: { location_id: departure_location&.id, is_pickup: true }))
        .distinct
    end

    def filter_by_destination(destination)
      return self if destination.blank?

      destination_location = Location.find_by('LOWER(name) = ?', destination.downcase)

      destination_stops = Stop.where(is_dropoff: true)
        .where('LOWER(address) ILIKE ?', "%#{destination.downcase}%")
        .or(Stop.where(location_id: destination_location&.id, is_dropoff: true))

      route_ids = destination_stops.pluck(:route_id)

      joins(route: :stops)
        .where(routes: { id: route_ids })
        .or(joins(route: :stops).where(stops: { location_id: destination_location&.id, is_dropoff: true }))
        .distinct
    end

    def filter_by_date(date)
      return self if date.blank?

      parsed_date = begin
        Date.parse(date)
      rescue StandardError
        nil
      end
      return self unless parsed_date

      where(departure_date: parsed_date)
    end

    def filter_by_price(price)
      return self if price.blank?

      where(price: ..price.to_i)
    end

    def sort_by_price(sort_by)
      case sort_by
      when 'price_high_to_low'
        order(price: :desc)
      when 'price_low_to_high'
        order(price: :asc)
      else
        self
      end
    end
  end
end
