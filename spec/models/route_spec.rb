require 'rails_helper'

RSpec.describe Route, type: :model do
  it 'creates a route with different locations' do
    route = create(:route, same_location: false)
    expect(route.start_location).not_to eq(route.end_location)
  end

  describe 'Associations' do
    it { should have_many(:stops).dependent(:destroy).inverse_of(:route) }
    it { should belong_to(:start_location).class_name('Location').inverse_of(:start_routes) }
    it { should belong_to(:end_location).class_name('Location').inverse_of(:end_routes) }
    it { should have_many(:schedules).dependent(:destroy).inverse_of(:route) }
    it { should accept_nested_attributes_for(:stops).allow_destroy(true) }
  end

  describe 'Validations' do
    let(:location1) { create(:location) }
    let(:location2) { create(:location) }

    it 'is valid with valid attributes' do
      route = build(:route, start_location: location1, end_location: location2)
      expect(route).to be_valid
    end

    it 'is invalid if start_location and end_location are the same' do
      route = build(:route, start_location: location1, end_location: location1)
      expect(route).not_to be_valid
      expect(route.errors[:base]).to include('Start and end location must be different')
      expect(route.errors[:end_location]).to include('must be different from start location')
    end
  end

  describe 'Scopes' do
    let!(:location1) { create(:location, name: 'Hanoi') }
    let!(:location2) { create(:location, name: 'Saigon') }
    let!(:location3) { create(:location, name: 'Danang') }

    let!(:route1) { create(:route, start_location: location1, end_location: location2) }
    let!(:route2) { create(:route, start_location: location2, end_location: location3) }
    let!(:route3) { create(:route, start_location: location3, end_location: location1) }

    context '.search' do
      it 'returns routes matching the start location' do
        expect(Route.search('Hanoi')).to include(route1, route3)
      end

      it 'returns routes matching the end location' do
        expect(Route.search('Danang')).to include(route2)
      end

      it 'returns all routes when query is blank' do
        expect(Route.search(nil)).to match_array([route1, route2, route3])
      end
    end

    context '.sort_by_param' do
      it 'sorts by newest' do
        expect(Route.sort_by_param('newest')).to eq(Route.order(created_at: :desc))
      end

      it 'sorts by oldest' do
        expect(Route.sort_by_param('oldest')).to eq(Route.order(created_at: :asc))
      end

      it 'sorts by start_location name' do
        sorted_routes = Route.joins(:start_location).order('locations.name ASC')
        expect(Route.sort_by_param('start_location')).to eq(sorted_routes)
      end

      it 'sorts by end_location name' do
        sorted_routes = Route.joins(:end_location).order('locations.name ASC')
        expect(Route.sort_by_param('end_location')).to eq(sorted_routes)
      end

      it 'returns default sorting (newest) for unknown params' do
        expect(Route.sort_by_param('unknown')).to eq(Route.order(created_at: :desc))
      end
    end
  end
end
