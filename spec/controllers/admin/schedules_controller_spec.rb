require 'rails_helper'

RSpec.describe Admin::SchedulesController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:route) { create(:route) }
  let(:coach) { create(:coach) }
  let(:schedule) { create(:schedule, route: route, coach: coach) }

  before { sign_in(admin) }

  describe 'GET #index' do
    before { get :index }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'assigns schedules' do
      expect(assigns(:schedules)).not_to be_nil
    end
  end

  describe 'GET #new' do
    before { get :new }

    it 'assigns a new schedule' do
      expect(assigns(:schedule)).to be_a_new(Schedule)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          schedule: {
            route_id: route.id,
            coach_id: coach.id,
            departure_date: Time.zone.today,
            departure_time: '10:00',
            price: 100.0
          }
        }
      end

      it 'creates a new schedule' do
        expect do
          post :create, params: valid_params
        end.to change(Schedule, :count).by(1)
      end

      it 'redirects to schedules index' do
        post :create, params: valid_params
        expect(response).to redirect_to(admin_schedules_path)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { schedule: { route_id: nil, coach_id: nil } } }

      it 'does not create a schedule' do
        expect do
          post :create, params: invalid_params
        end.not_to change(Schedule, :count)
      end

      it 'redirects back with a warning' do
        post :create, params: invalid_params
        expect(flash[:warning]).to eq('Fail to create schedule')
      end
    end
  end

  describe 'PATCH #update' do
    let(:update_params) do
      {
        id: schedule.id,
        schedule: {
          price: 150.0
        }
      }
    end

    it 'updates the schedule' do
      patch :update, params: update_params
      expect(schedule.reload.price).to eq(150.0)
    end

    it 'redirects to schedules index' do
      patch :update, params: update_params
      expect(response).to redirect_to(admin_schedules_path)
    end
  end

  describe 'DELETE #destroy' do
    context 'when successful' do
      it 'deletes the schedule' do
        schedule
        expect do
          delete :destroy, params: { id: schedule.id }
        end.to change(Schedule, :count).by(-1)
      end

      it 'redirects to schedules index' do
        delete :destroy, params: { id: schedule.id }
        expect(response).to redirect_to(admin_schedules_path)
      end
    end

    context 'when using Turbo Stream' do
      before do
        delete :destroy, params: { id: schedule.id }, format: :turbo_stream
      end

      it 'responds with turbo stream' do
        expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      end
    end
  end
end
