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
      @route = Route.includes(:stops).find(params[:id])

      @route.stops.build if @route.stops.empty?
    end

    def create
      # Start the transaction block
      route_params_without_stops = route_params.except(:stops_attributes)
      ActiveRecord::Base.transaction do
        # Create the route
        @route = Route.create!(route_params_without_stops)

        if params[:route][:stops_attributes][:location_id].present?
          create_or_update_stops(@route, params[:route][:stops_attributes])
        else
          create_default_stops(@route)
        end
        handle_success('Route created successfully')

        if @route.errors.any? || @route.stops.any?(&:invalid?)
          raise ActiveRecord::Rollback, 'Stops validation failed'
        end
      end
    rescue ActiveRecord::Rollback
      handle_failure(@route, 'admin/coach_routes/shared/form')
    end

    def update
      stops_attributes = route_params[:stops_attributes]

      if @route.update(route_params.except(:stops_attributes))
        create_or_update_stops(@route, stops_attributes)

        handle_success('Route updated successfully')
      else
        handle_failure(@route, 'admin/coach_routes/shared/form')
      end
    end

    def destroy
      if @route.destroy
        handle_success('Route deleted successfully')
      else
        handle_failure('Failed to delete route')
      end
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

    def handle_success(message)
      flash[:success] = message
      respond_to do |format|
        format.html { redirect_to admin_coach_routes_path }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('modal_routes', ''),
            turbo_stream.update(
              'flash_message',
              partial: 'layouts/flash',
              locals: { message: message, type: 'success' }
            )
          ]
        end
      end
    end

    def handle_failure(resource, partial_path)
      error_message = resource.errors.full_messages.to_sentence.presence || 'An error occurred. Please try again.'
      flash[:warning] = error_message
      render turbo_stream: [
        turbo_stream.update(
          'modal_routes',
          partial: partial_path,
          locals: { route: resource }
        ),
        turbo_stream.update(
          'flash_message',
          partial: 'layouts/flash',
          locals: { message: error_message, type: 'warning' }
        )
      ]
    end

    def create_default_stops(route)
      # Start stop
      route.stops.create!(
        location_id: route.start_location_id,
        stop_order: 1,
        time_range: 0,
        address: params[:route][:start_location_address],
        is_pickup: true,
        is_dropoff: false
      )

      # End stop
      route.stops.create!(
        location_id: route.end_location_id,
        stop_order: 2,
        time_range: 200,
        address: params[:route][:end_location_address],
        is_pickup: false,
        is_dropoff: true
      )
    end

    def create_or_update_stops(route, stops_attributes)
      stops_attributes.to_unsafe_h.each_with_index do |(_key, stop_params), index|
        stop = route.stops.find_by(location_id: stop_params[:location_id])

        if stop
          stop.update!(
            stop_order: stop_params[:stop_order],
            time_range: 20,
            address: stop_params[:address],
            is_pickup: stop_params[:is_pickup],
            is_dropoff: stop_params[:is_dropoff]
          )
        else
          # Create new stop if it doesn't exist
          route.stops.create!(
            location_id: stop_params[:location_id],
            stop_order: index + 1,
            time_range: 20,
            address: stop_params[:address],
            is_pickup: stop_params[:is_pickup],
            is_dropoff: stop_params[:is_dropoff]
          )
        end
      end
    end
  end
end
