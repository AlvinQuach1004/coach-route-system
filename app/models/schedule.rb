# == Schema Information
#
# Table name: schedules
#
#  id             :uuid             not null, primary key
#  departure_date :date
#  departure_time :time
#  price          :decimal(, )
#  status         :string           default("scheduled")
#  tickets_count  :integer          default(0)
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
  accepts_nested_attributes_for :tickets, allow_destroy: true, reject_if: :all_blank

  # Callbacks
  after_create :update_coach_status
  after_update :manage_coach_status, if: :coach_id_changed?
  after_destroy :reset_coach_status

  # Validations
  validates :departure_date, presence: true
  validates :departure_time, presence: true
  validate :departure_date_cannot_be_in_the_past

  # Constants
  module Status
    SCHEDULED = 'scheduled'.freeze
    ONGOING = 'ongoing'.freeze
    COMPLETED = 'completed'.freeze
    CANCELLED = 'cancelled'.freeze
    DELAYED = 'delayed'.freeze

    ALL = [SCHEDULED, ONGOING, COMPLETED, CANCELLED, DELAYED].freeze
  end

  # Enumerize
  enum :status,
    {
      scheduled: Status::SCHEDULED,
      ongoing: Status::ONGOING,
      completed: Status::COMPLETED,
      cancelled: Schedule::Status::CANCELLED,
      delayed: Schedule::Status::DELAYED
    },
    default: Status::SCHEDULED

  # Public methods
  def formatted_departure_date
    departure_date.strftime('%d/%m/%Y') if departure_date.present?
  end

  def formatted_departure_time
    departure_time.strftime('%H:%M') if departure_time.present?
  end

  def seat_available?(seat_number)
    !tickets.exists?(seat_number: seat_number, status: [Ticket::Status::BOOKED, Ticket::Status::PAID])
  end

  def seat_rows_by_type
    case coach.coach_type # rubocop:disable Style/HashLikeCase
    when 'sleeper'
      { upper: (1..18), lower: (1..18) }  # 36 seats total
    when 'room'
      { upper: (1..16), lower: (1..16) }  # 32 seats total
    when 'limousine'
      { upper: (1..14), lower: (1..14) }  # 28 seats total
    end
  end

  private

  def departure_date_cannot_be_in_the_past
    if departure_date.present? && departure_date < Date.current
      errors.add(:departure_date, 'cannot be in the past')
    end
  end

  def update_coach_status
    coach.inuse! if coach.available?
  end

  def reset_coach_status
    coach.available! if coach.schedules.where(departure_date: Time.zone.today..).empty?
  end

  def manage_coach_status
    previous_coach = Coach.find(coach_id_was)
    new_coach = coach
    # Update previous status to available if departure_date of schedules > current
    previous_coach.available! if previous_coach.schedules.where(departure_date: Time.zone.today..).empty?
    new_coach.inuse! if new_coach.available?
  end
end
