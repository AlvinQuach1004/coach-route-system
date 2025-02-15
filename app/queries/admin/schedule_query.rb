module Admin
  class ScheduleQuery < ApplicationQuery
    def initialize(scope:, params: {}) # rubocop:disable Lint/MissingSuper
      @scope = scope
      @params = params
    end

    def call
      {
        total: filtered_scope.size,
        schedules: filtered_scope.distinct
      }
    end

    private

    def filtered_scope
      # Conditionally extend the scope to include the necessary associations based on params
      scope = @scope
      scope = include_route_associations(scope) if needs_route_associations?

      scope.extending(Scopes)
        .search(@params[:search])
        .filter(@params)
    end

    # Check if the route associations need to be included
    def needs_route_associations?
      @params[:search].present? || @params[:route_id].present? || @params[:start_date].present?
    end

    def include_route_associations(scope)
      # Include only necessary associations
      scope.includes(route: [:start_location, :end_location])
    end

    module Scopes
      def search(search_term)
        return self if search_term.blank?

        joins(<<-SQL.squish)
          INNER JOIN routes ON routes.id = schedules.route_id
          INNER JOIN locations AS start_locations ON routes.start_location_id = start_locations.id
          INNER JOIN locations AS end_locations ON routes.end_location_id = end_locations.id
          INNER JOIN coaches ON coaches.id = schedules.coach_id
        SQL
          .where(
            'start_locations.name ILIKE :search OR end_locations.name ILIKE :search OR coaches.license_plate ILIKE :search',
            search: "%#{search_term}%"
          )
      end

      def filter(params)
        relation = self

        relation = filter_by_route(relation, params[:route_id])
        relation = filter_by_coach(relation, params[:coach_id])
        relation = filter_by_date(relation, params[:start_date])
        relation = filter_by_time(relation, params[:departure_time])
        filter_by_price_range(relation, params[:min_price], params[:max_price])
      end

      private

      def filter_by_route(relation, route_id)
        return relation if route_id.blank?

        relation.where(route_id: route_id)
      end

      def filter_by_coach(relation, coach_id)
        return relation if coach_id.blank?

        relation.where(coach_id: coach_id)
      end

      def filter_by_date(relation, start_date)
        return relation if start_date.blank?

        begin
          parsed_date = Date.parse(start_date.to_s)
          relation.where(departure_date: parsed_date)
        rescue ArgumentError
          relation
        end
      end

      def filter_by_time(relation, departure_time)
        return relation if departure_time.blank?

        begin
          parsed_time = Time.zone.parse(departure_time.to_s)
          relation.where(departure_time: parsed_time)
        rescue ArgumentError
          relation
        end
      end

      def filter_by_price_range(relation, min_price, max_price)
        return relation unless min_price.present? && max_price.present?

        relation.where(price: min_price..max_price)
      end
    end
  end
end
