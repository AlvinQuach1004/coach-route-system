module Admin
  class SchedulesController < BaseController
    before_action :set_schedule, only: [:edit, :update, :destroy]
    before_action :load_dependencies, only: [:new, :edit, :create, :update, :index]

    def index
      query = Admin::ScheduleQuery.new(scope: Schedule.includes(route: [:start_location, :end_location], coach: []), params: params)
      result = query.call

      @total_schedules = result[:total]
      @pagy, @schedules = pagy(result[:schedules])

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
        flash[:success] = 'Schedule was created successfully'
      else
        flash[:warning] = 'Fail to create schedule'
      end
      redirect_to admin_schedules_path
    end

    def update
      if @schedule.update(schedule_params)
        flash[:success] = 'Schedule was updated successfully'
      else
        flash[:warning] = 'Fail to update schedule'
      end
      redirect_to admin_schedules_path
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
        flash[:warning] = 'Fail to destroy schedule'
        redirect_to admin_schedules_path
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
  end
end
