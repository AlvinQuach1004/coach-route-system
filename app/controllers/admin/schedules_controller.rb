module Admin
  class SchedulesController < BaseController
    before_action :set_schedule, only: [:edit, :update, :destroy]
    before_action :load_dependencies, only: [:new, :edit, :create, :update, :index]

    def index
      query = Admin::ScheduleQuery.new(params)
      @total_schedules = query.count
      @pagy, @schedules = pagy(query.result)

      respond_to do |format|
        format.html
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'schedules_table',
            partial: 'admin/schedules/shared/schedules',
            locals: { schedules: @schedules }
          )
        end
      end
    end

    def new
      @schedule = Schedule.new
    end

    def edit; end

    def create
      @schedule = Schedule.new(schedule_params)
      if @schedule.save
        handle_success('Schedule was created successfully')
      else
        handle_failure(@schedule)
      end
    end

    def update
      if @schedule.update(schedule_params)
        handle_success('Schedule was updated successfully')
      else
        handle_failure(@schedule)
      end
    end

    def destroy
      if @schedule.destroy
        respond_to do |format|
          format.html { redirect_to admin_schedules_path(page: params[:page]), flash: { success: 'Route was deleted successfully' } }
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.remove("schedule_#{@schedule.id}"),
              turbo_stream.update(
                'flash_message',
                partial: 'layouts/flash',
                locals: { type: 'success', message: 'Schedule was deleted successfully' }
              )
            ]
          end
        end
      else
        handle_failure(@schedule)
      end
    end

    private

    def set_schedule
      @schedule = Schedule.find(params[:id])
    end

    def load_dependencies
      @routes = Route.joins('INNER JOIN locations AS start_locations ON routes.start_location_id = start_locations.id')
        .joins('INNER JOIN locations AS end_locations ON routes.end_location_id = end_locations.id')
        .select('routes.*, start_locations.name as start_name, end_locations.name as end_name')

      # Fetch coaches
      @coaches = Coach.available
    end

    def schedule_params
      params.require(:schedule).permit(
        :route_id,
        :coach_id,
        :departure_date,
        :departure_time,
        :price,
        tickets_attributes: [:id, :_destroy]
      )
    end

    def handle_success(message)
      respond_to do |format|
        format.html { redirect_to admin_schedules_path, flash: { success: message } }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('modal_schedules', ''),
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
          'schedules_table',
          partial: 'admin/schedules/shared/schedules',
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
