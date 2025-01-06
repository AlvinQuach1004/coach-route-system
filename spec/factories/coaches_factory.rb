FactoryBot.define do
  factory :coach do
    license_plate { Faker::Vehicle.license_plate }
    type { ['sleeper', 'limousine', 'room'].sample }
    capacity { Faker::Number.between(from: 30, to: 50) }
  end
end
