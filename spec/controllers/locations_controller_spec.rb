require 'rails_helper'

RSpec.describe LocationsController, type: :controller do
  describe 'GET #search' do
    before do
      # Create test locations
      @location1 = create(:location, name: 'Ho Chi Minh City')
      @location2 = create(:location, name: 'Hanoi')
      @location3 = create(:location, name: 'Ha Long Bay')
      @location4 = create(:location, name: 'Da Nang')
      create(:location, name: 'Bangkok')
      create(:location, name: 'Singapore')
    end

    context 'with matching query' do
      it 'returns locations matching the search query' do
        get :search, params: { query: 'ha' }, format: :json

        json_response = response.parsed_body
        expect(json_response.length).to eq(2)
        expect(json_response.map { |loc| loc['name'] }).to contain_exactly('Hanoi', 'Ha Long Bay')
      end

      it 'returns locations in the correct format' do
        get :search, params: { query: 'ho chi' }, format: :json

        json_response = response.parsed_body
        expect(json_response.first).to include(
          'id' => @location1.id,
          'name' => 'Ho Chi Minh City'
        )
      end

      it 'is case insensitive' do
        get :search, params: { query: 'HO CHI' }, format: :json

        json_response = response.parsed_body
        expect(json_response.length).to eq(1)
        expect(json_response.first['name']).to eq('Ho Chi Minh City')
      end
    end

    context 'with non-matching query' do
      it 'returns empty array when no matches found' do
        get :search, params: { query: 'xyz' }, format: :json

        json_response = response.parsed_body
        expect(json_response).to be_empty
      end
    end

    context 'with limit' do
      before do
        # Create additional locations to test limit
        create(:location, name: 'Ha Tinh')
        create(:location, name: 'Ha Nam')
        create(:location, name: 'Ha Giang')
      end

      it 'limits results to 10 locations' do
        get :search, params: { query: 'ha' }, format: :json

        json_response = response.parsed_body
        expect(json_response.length).to be <= 10
      end
    end

    context 'with special characters' do
      it 'handles special characters safely' do
        get :search, params: { query: '%_ha' }, format: :json

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
