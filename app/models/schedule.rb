# == Schema Information
#
# Table name: schedules
#
#  id             :uuid             not null, primary key
#  departure_date :date
#  departure_time :time
#  price          :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  coach_id       :uuid             not null
#  route_id       :uuid             not null
#
# Indexes
#
#  index_schedules_on_coach_id  (coach_id)
#  index_schedules_on_route_id  (route_id)
#
# Foreign Keys
#
#  fk_rails_...  (coach_id => coaches.id)
#  fk_rails_...  (route_id => routes.id)
#
class Schedule < ApplicationRecord
  # Associations
  belongs_to :route, inverse_of: :schedules
  belongs_to :coach, inverse_of: :schedules
  has_many :tickets, dependent: :destroy

  # Validations
  validates :departure_date, presence: true
  validates :departure_time, presence: true
  validate :departure_date_cannot_be_in_the_past

  # Public methods
  def formatted_departure_date
    departure_date.strftime('%d/%m/%Y') if departure_date.present?
  end

  def formatted_departure_time
    departure_time.strftime('%H:%M:%S') if departure_time.present?
  end

  def seat_available?(seat_number)
    !tickets.exists?(seat_number: seat_number)
  end

  private

  def departure_date_cannot_be_in_the_past
    if departure_date.present? && departure_date < Date.current
      errors.add(:departure_date, 'cannot be in the past')
    end
  end
end
