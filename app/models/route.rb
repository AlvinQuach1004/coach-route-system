# == Schema Information
#
# Table name: routes
#
#  id                :uuid             not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  end_location_id   :uuid             not null
#  start_location_id :uuid             not null
#
# Indexes
#
#  index_routes_on_end_location_id    (end_location_id)
#  index_routes_on_start_location_id  (start_location_id)
#
# Foreign Keys
#
#  fk_rails_...  (end_location_id => locations.id)
#  fk_rails_...  (start_location_id => locations.id)
#
class Route < ApplicationRecord
  belongs_to :start_location, class_name: 'Location', inverse_of: :start_routes
  belongs_to :end_location, class_name: 'Location', inverse_of: :end_routes
  has_many :schedules, dependent: :destroy, inverse_of: :route
  validate :start_and_end_location_cannot_be_the_same

  private

  def start_and_end_location_cannot_be_the_same
    if start_location == end_location
      errors.add(:end_location, 'must be different from start location')
    end
  end
end
