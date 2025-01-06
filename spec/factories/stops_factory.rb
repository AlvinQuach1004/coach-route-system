FactoryBot.define do
  factory :stop do
    route
    location
    stop_order { Faker::Number.between(from: 1, to: 10) }
    time_range { Faker::Number.between(from: 1, to: 12) }
  end
end
