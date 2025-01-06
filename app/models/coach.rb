# == Schema Information
#
# Table name: coaches
#
#  id            :uuid             not null, primary key
#  capacity      :integer
#  license_plate :string
#  type          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Coach < ApplicationRecord
  has_many :schedules, dependent: :destroy, inverse_of: :coach
end
