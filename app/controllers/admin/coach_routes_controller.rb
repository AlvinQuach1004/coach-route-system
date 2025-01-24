module Admin
  class CoachRoutesController < BaseController
    before_action :set_route, only: %i[edit update destroy]

    def index
      @routes = Route.includes(:start_location, :end_location, :stops)
        .search(params[:search])
        .sort_by_param(params[:sort_by])
      @total_routes = @routes.size
      @pagy, @routes = pagy(@routes, page: params[:page])

      respond_to do |format|
        format.html
        format.turbo_stream { render turbo_stream: turbo_stream.update('modal_routes', '') }
      end
    end

    def new
      @route = Route.new
      @route.stops.build
    end

    def edit
      @route = Route.find(params[:id])
      @route.stops.build if @route.stops.empty?
    end

    def create # rubocop:disable Metrics/AbcSize,Metrics/PerceivedComplexity
      route_params_filtered = route_params
      if params[:route][:stops_attributes].blank? || params[:route][:stops_attributes].values.all? { |stop| stop[:location_id].blank? }
        route_params_filtered = route_params.except(:stops_attributes)
      end

      @route = Route.new(route_params_filtered)
      if @route.save
        if params[:route][:stops_attributes].present? && params[:route][:stops_attributes].values.any? { |stop| stop[:location_id].present? }
          create_stops_based_on_locations(@route)
        else
          create_default_stops
        end
        handle_success('Route created successfully')
      else
        handle_failure(@route)
      end
    end

    def update # rubocop:disable Metrics/AbcSize,Metrics/PerceivedComplexity,Metrics/MethodLength
      if @route.update(route_params)
        if params[:route][:stops_attributes].present?
          params[:route][:stops_attributes].each do |_index, stop_params|
            next if stop_params[:location_id].blank?

            if stop_params[:id].present?
              # Update existing stop
              stop = @route.stops.find(stop_params[:id])
              stop.update(
                location_id: stop_params[:location_id],
                stop_order: stop_params[:stop_order],
                time_range: stop_params[:time_range],
                address: stop_params[:address],
                is_pickup: stop_params[:is_pickup],
                is_dropoff: stop_params[:is_dropoff]
              )
            else
              # Check if a stop with the same location_id already exists
              existing_stop = @route.stops.find_by(location_id: stop_params[:location_id])
              if existing_stop
                # Update the existing stop
                existing_stop.update(
                  location_id: stop_params[:location_id],
                  stop_order: stop_params[:stop_order],
                  time_range: stop_params[:time_range],
                  address: stop_params[:address],
                  is_pickup: stop_params[:is_pickup],
                  is_dropoff: stop_params[:is_dropoff]
                )
              else
                # Create new stop
                max_stop_order = @route.stops.maximum(:stop_order) || 1
                @route.stops.create!(
                  location_id: stop_params[:location_id],
                  stop_order: max_stop_order + 1,
                  time_range: stop_params[:time_range],
                  address: stop_params[:address],
                  is_pickup: stop_params[:is_pickup],
                  is_dropoff: stop_params[:is_dropoff]
                )
              end
            end
          end

          # Update stop_order for end location
          max_stop_order = @route.stops.maximum(:stop_order) || 1
          @route.stops.where(location_id: route_params[:end_location_id]).update_all(stop_order: max_stop_order + 1) # rubocop:disable Rails/SkipsModelValidations
        end

        handle_success('Route was updated successfully')
      else
        handle_failure(@route)
      end
    end

    def destroy
      @route.destroy
      handle_success('Route was deleted successfully')
    rescue ActiveRecord::RecordNotFound
      handle_failure(@route)
    end

    private

    def set_route
      @route = Route.includes(:stops).find(params[:id])
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
    end

    def create_stops_based_on_locations(route) # rubocop:disable Metrics/MethodLength
      # Ensure no duplicate stops
      route.stops.destroy_all

      # Create stop for start location
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

      # Create stops for other locations
      params[:route][:stops_attributes].each do |_index, stop_params|
        next if stop_params[:location_id].blank? || stop_params[:_destroy] == '1'

        Stop.create!(
          route_id: route.id,
          location_id: stop_params[:location_id],
          stop_order: stop_order,
          time_range: stop_params[:time_range].to_i,
          address: stop_params[:address],
          is_pickup: stop_params[:is_pickup] == '1',
          is_dropoff: stop_params[:is_dropoff] == '1'
        )
        stop_order += 1
      end

      # Create stop for end location
      Stop.create!(
        route_id: route.id,
        location_id: route.end_location_id,
        stop_order: stop_order,
        time_range: 200,
        address: params[:route][:end_location_address],
        is_pickup: false,
        is_dropoff: true
      )
    end

    def handle_success(message)
      respond_to do |format|
        format.html { redirect_to admin_coach_routes_path, flash: { success: message } }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('modal_routes', ''),
            turbo_stream.update(
              'flash_message',
              partial: 'layouts/flash',
              locals: { type: 'success', message: message }
            )
          ]
        end
      end
    end

    def handle_failure(resource)
      error_message = resource.errors.full_messages.to_sentence.presence || 'An error occurred. Please try again.'

      render turbo_stream: [
        turbo_stream.update(
          'modal_routes',
          partial: 'admin/coach_routes/shared/routes',
          locals: { route: resource }
        ),
        turbo_stream.update(
          'flash_message',
          partial: 'layouts/flash',
          locals: { type: 'warning', message: error_message }
        )
      ]
    end
  end
end
