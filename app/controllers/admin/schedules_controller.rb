module Admin
  class SchedulesController < BaseController
    before_action :set_schedule, only: [:edit, :update, :destroy]
    before_action :load_dependencies, only: [:new, :edit, :create, :update, :index]

    def index
      query = Admin::ScheduleQuery.new(scope: conditional_scope, params: params)
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
        handle_success(t('.success'))
      else
        handle_failure(t('.failure'))
      end
    end

    def update
      if @schedule.update(schedule_params)
        handle_success(t('.success'))
      else
        handle_failure(t('.failure'))
      end
    end

    def destroy
      if @schedule.destroy
        respond_to do |format|
          format.html { handle_success(t('.success'), redirect: admin_schedules_path(page: params[:page])) }
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.remove("schedule_#{@schedule.id}"),
              turbo_stream.update(
                'toast_flash',
                partial: 'layouts/flash',
                locals: { type: 'success', message: t('.success') }
              )
            ]
          end
        end
      else
        handle_failure(t('.failure'))
      end
    end

    private

    def conditional_scope
      scope = Schedule.includes(coach: [])
      scope = Schedule.includes(route: [:start_location, :end_location]) if needs_route_associations?
      scope
    end

    def needs_route_associations?
      params[:search].present? || params[:route_id].present? || params[:departure_date].present?
    end

    def set_schedule
      @schedule = Schedule.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      Sentry.capture_message("Schedule not found: #{params[:id]}")
      handle_failure(t('admin.schedules.errors.not_found'), redirect: admin_schedules_path)
    end

    def load_dependencies
      @routes = Route.joins('INNER JOIN locations AS start_locations ON routes.start_location_id = start_locations.id')
        .joins('INNER JOIN locations AS end_locations ON routes.end_location_id = end_locations.id')
        .select('routes.*, start_locations.name as start_name, end_locations.name as end_name')

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

    def handle_success(message, redirect: admin_schedules_path)
      respond_to do |format|
        format.html { redirect_to redirect, flash: { success: message } }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            'toast_flash',
            partial: 'layouts/flash',
            locals: { type: 'success', message: message }
          )
        end
      end
    end

    def handle_failure(message, redirect: admin_schedules_path)
      respond_to do |format|
        format.html { redirect_to redirect, flash: { warning: message } }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            'toast_flash',
            partial: 'layouts/flash',
            locals: { type: 'warning', message: message }
          )
        end
      end
    end
  end
end
