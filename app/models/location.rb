# == Schema Information
#
# Table name: locations
#
#  id         :uuid             not null, primary key
#  latitude   :decimal(9, 6)
#  longitude  :decimal(9, 6)
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Location < ApplicationRecord
  # Associations
  has_many :stops, dependent: :destroy, inverse_of: :location
  has_many :start_routes, class_name: 'Route', foreign_key: 'start_location_id', dependent: :destroy, inverse_of: :start_location
  has_many :end_routes, class_name: 'Route', foreign_key: 'end_location_id', dependent: :destroy, inverse_of: :end_location

  # Validations
  validates :name, presence: true
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
end
