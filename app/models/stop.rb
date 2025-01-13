# == Schema Information
#
# Table name: stops
#
#  id                :uuid             not null, primary key
#  address           :string
#  is_dropoff        :boolean          default(FALSE)
#  is_pickup         :boolean          default(FALSE)
#  latitude_address  :decimal(9, 6)
#  longitude_address :decimal(9, 6)
#  stop_order        :integer
#  time_range        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  location_id       :uuid             not null
#  route_id          :uuid             not null
#
# Indexes
#
#  index_stops_on_location_id  (location_id)
#  index_stops_on_route_id     (route_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (route_id => routes.id)
#
class Stop < ApplicationRecord
  # Associations
  belongs_to :route, inverse_of: :stops
  belongs_to :location, inverse_of: :stops
  has_many :start_stops, class_name: 'Booking', foreign_key: :start_stop_id, dependent: :destroy, inverse_of: :start_stop
  has_many :end_stops, class_name: 'Booking', foreign_key: :end_stop_id, dependent: :destroy, inverse_of: :end_stop

  # Validations
  validates :stop_order, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :time_range, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 360 }
end
