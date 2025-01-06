require 'rails_helper'

RSpec.describe 'RoutePages', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/route_pages/index'
      expect(response).to have_http_status(:success)
    end
  end
end
