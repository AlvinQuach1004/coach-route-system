module Admin
  class CoachRoutesController < BaseController
    before_action :set_route, only: %i[edit update destroy]

    def index
      @routes = Route.search(params[:search])
        .sort_by_param(params[:sort_by])

      @routes = @routes.includes(:start_location, :end_location, :stops) if need_associations?
      @total_routes = @routes.size
      @pagy, @routes = pagy(@routes, page: params[:page])

      respond_to do |format|
        format.html
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'routes_table',
            partial: 'admin/coach_routes/shared/routes',
            locals: { routes: @routes }
          )
        end
      end
    rescue StandardError => e
      handle_failure(e.message)
    end

    def new
      @route = Route.new
      @route.stops.build
    rescue StandardError => e
      handle_failure(e.message)
    end

    def edit
      @route = Route.find(params[:id])
      @route.stops.build if @route.stops.empty?
    rescue ActiveRecord::RecordNotFound
      handle_failure(t('admin.coach_routes.messages.not_found'))
    rescue StandardError => e
      handle_failure(e.message)
    end

    def create # rubocop:disable Metrics/AbcSize,Metrics/PerceivedComplexity
      route_params_filtered = route_params
      if params[:route][:stops_attributes].blank? || params[:route][:stops_attributes].values.all? { |stop| stop[:location_id].blank? }
        route_params_filtered = route_params.except(:stops_attributes)
      end
      @route = Route.find_or_initialize_by(
        start_location_id: route_params_filtered[:start_location_id],
        end_location_id: route_params_filtered[:end_location_id]
      )
      if @route.persisted?
        handle_failure(t('admin.coach_routes.messages.already_exists'))
        return
      end
      if @route.update(route_params_filtered)
        if params[:route][:stops_attributes].present? && params[:route][:stops_attributes].values.any? { |stop| stop[:location_id].present? }
          create_stops_based_on_locations(@route)
        else
          create_default_stops
        end
        handle_success(t('admin.coach_routes.messages.create_success'))
      else
        handle_failure(t('admin.coach_routes.messages.create_failure'))
      end
    rescue StandardError => e
      handle_failure(e.message)
    end

    def update # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/PerceivedComplexity
      if @route.update(route_params)
        if params[:route][:stops_attributes].present?
          params[:route][:stops_attributes].each do |_index, stop_params|
            next if stop_params[:location_id].blank?

            begin
              if stop_params[:id].present?
                stop = @route.stops.find(stop_params[:id])
                stop.update!(stop_params.permit(:location_id, :stop_order, :time_range, :address, :is_pickup, :is_dropoff))
              else
                existing_stop = @route.stops.find_by(location_id: stop_params[:location_id])
                if existing_stop
                  existing_stop.update!(stop_params.permit(:location_id, :stop_order, :time_range, :address, :is_pickup, :is_dropoff))
                else
                  max_stop_order = @route.stops.maximum(:stop_order) || 1
                  @route.stops.create!(stop_params.permit(:location_id, :time_range, :address, :is_pickup, :is_dropoff).merge(stop_order: max_stop_order + 1))
                end
              end
            rescue ActiveRecord::RecordInvalid => e
              handle_failure(e.message)
            end
          end

          max_stop_order = @route.stops.maximum(:stop_order) || 1
          @route.stops.where(location_id: route_params[:end_location_id]).update_all(stop_order: max_stop_order + 1) # rubocop:disable Rails/SkipsModelValidations
        end

        handle_success(t('admin.coach_routes.messages.update_success'))
      else
        handle_failure(t('admin.coach_routes.messages.update_failure'))
      end
    rescue ActiveRecord::RecordNotFound
      handle_failure(t('admin.coach_routes.messages.not_found'))
    rescue StandardError => e
      handle_failure(e.message)
    end

    def destroy
      @route.destroy!
      handle_success(t('admin.coach_routes.messages.delete_success'))
    rescue ActiveRecord::RecordNotFound
      Sentry.capture_message("Route not found: #{params[:id]}")
      handle_failure(t('admin.coach_routes.messages.not_found'))
    rescue StandardError => e
      handle_failure(e.message)
    end

    private

    def need_associations?
      params[:search].present? || params[:sort_by].present?
    end

    def set_route
      @route = Route.includes(:stops).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      handle_failure(t('admin.coach_routes.messages.not_found'))
    end

    def route_params
      params.require(:route).permit(
        :start_location_id,
        :end_location_id,
        stops_attributes: [
          :id,
          :location_id,
          :time_range,
          :is_pickup,
          :is_dropoff,
          :stop_order,
          :address,
          :_destroy
        ]
      )
    end

    def create_default_stops
      @route.stops.create!(
        location_id: @route.start_location_id,
        stop_order: 1,
        time_range: 0,
        address: params[:route][:start_location_address],
        is_pickup: true,
        is_dropoff: false
      )

      @route.stops.create!(
        location_id: @route.end_location_id,
        stop_order: 2,
        time_range: 200,
        address: params[:route][:end_location_address],
        is_pickup: false,
        is_dropoff: true
      )
    rescue StandardError => e
      handle_failure(e.message)
    end

    def create_stops_based_on_locations(route)
      route.stops.destroy_all

      Stop.create!(
        route_id: route.id,
        location_id: route.start_location_id,
        stop_order: 1,
        time_range: 0,
        address: params[:route][:start_location_address],
        is_pickup: false,
        is_dropoff: true
      )

      stop_order = 2

      params[:route][:stops_attributes].each do |_index, stop_params|
        next if stop_params[:location_id].blank? || stop_params[:_destroy] == '1'

        Stop.create!(stop_params.permit(:location_id, :time_range, :address, :is_pickup, :is_dropoff).merge(route_id: route.id, stop_order: stop_order))
        stop_order += 1
      end

      Stop.create!(
        route_id: route.id,
        location_id: route.end_location_id,
        stop_order: stop_order,
        time_range: 200,
        address: params[:route][:end_location_address],
        is_pickup: false,
        is_dropoff: true
      )
    rescue StandardError => e
      handle_failure(e.message)
    end

    def handle_failure(message)
      respond_to do |format|
        format.html { redirect_back fallback_location: admin_coach_routes_path, alert: message }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('toast_flash', partial: 'layouts/flash', locals: { message: message, type: :error }) }
      end
    end

    def handle_success(message)
      respond_to do |format|
        format.html { redirect_to admin_coach_routes_path, success: message }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('toast_flash', partial: 'layouts/flash', locals: { message: message, type: :success }) }
      end
    end
  end
end
