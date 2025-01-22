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
  # Associations
  has_many :stops, dependent: :destroy, inverse_of: :route
  belongs_to :start_location, class_name: 'Location', inverse_of: :start_routes
  belongs_to :end_location, class_name: 'Location', inverse_of: :end_routes
  has_many :schedules, dependent: :destroy, inverse_of: :route
  accepts_nested_attributes_for :stops, allow_destroy: true

  # Validations
  validate :start_and_end_location_cannot_be_the_same
  validate :different_locations

  # Scope
  scope :search,
    ->(query) do
      return all if query.blank?

      joins(
        'INNER JOIN locations AS start_locations ON start_locations.id = routes.start_location_id'
      ).joins(
        'INNER JOIN locations AS end_locations ON end_locations.id = routes.end_location_id'
      ).where(
        'start_locations.name ILIKE :query OR end_locations.name ILIKE :query',
        query: "%#{query}%"
      )
    end

  scope :sort_by_param,
    ->(sort_param) do
      return all if sort_param.blank?

      case sort_param
      when 'newest'
        order(created_at: :desc)
      when 'oldest'
        order(created_at: :asc)
      when 'start_location'
        joins(:start_location).order('locations.name ASC')
      when 'end_location'
        joins(:end_location).order('locations.name ASC')
      else
        order(created_at: :desc)
      end
    end

  private

  def different_locations
    if start_location_id == end_location_id
      errors.add(:base, 'Start and end location must be different')
    end
  end

  def start_and_end_location_cannot_be_the_same
    if start_location == end_location
      errors.add(:end_location, 'must be different from start location')
    end
  end
end
