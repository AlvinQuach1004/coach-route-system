FactoryBot.define do
  factory :coach do
    license_plate { Faker::Vehicle.license_plate }
    coach_type { ['sleeper', 'limousine', 'room'].sample }
    capacity { Faker::Number.between(from: 28, to: 36) }
  end
end
