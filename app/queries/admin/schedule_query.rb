module Admin
  class ScheduleQuery < ApplicationQuery
    def initialize(params) # rubocop:disable Lint/MissingSuper
      @params = params
      @relation = Schedule.includes(route: [:start_location, :end_location], coach: [])
    end

    def result
      filter_by_search
      filter_by_route
      filter_by_coach
      filter_by_date
      filter_by_time
      filter_by_price
      @relation
    end

    def count
      result.size
    end

    private

    def filter_by_search
      return if @params[:search].blank?

      search_term = "%#{@params[:search]}%"
      @relation = @relation.joins('INNER JOIN routes ON routes.id = schedules.route_id')
        .joins('INNER JOIN locations AS start_locations ON routes.start_location_id = start_locations.id')
        .joins('INNER JOIN locations AS end_locations ON routes.end_location_id = end_locations.id')
        .joins('INNER JOIN coaches ON coaches.id = schedules.coach_id')
        .where('start_locations.name ILIKE :search_term OR end_locations.name ILIKE :search_term OR coaches.license_plate ILIKE :search_term', search_term: search_term) # rubocop:disable Layout/LineLength
    end

    def filter_by_route
      return if @params[:route_id].blank?

      @relation = @relation.where(route_id: @params[:route_id])
    end

    def filter_by_coach
      return if @params[:coach_id].blank?

      @relation = @relation.where(coach_id: @params[:coach_id])
    end

    def filter_by_date
      return if @params[:start_date].blank?

      start_date = Date.parse(@params[:start_date])
      @relation = @relation.where('DATE(departure_date) = ?', start_date)
    end

    def filter_by_time
      return if @params[:departure_time].blank?

      departure_time = Time.zone.parse(@params[:departure_time])
      @relation = @relation.where(
        'EXTRACT(HOUR FROM departure_time) = ? AND EXTRACT(MINUTE FROM departure_time) = ?',
        departure_time.hour,
        departure_time.min
      )
    end

    def filter_by_price
      return unless @params[:min_price].present? && @params[:max_price].present?

      @relation = @relation.where(price: @params[:min_price]..@params[:max_price])
    end
  end
end
