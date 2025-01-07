FactoryBot.define do
  factory :schedule do
    route
    coach
    price { Faker::Number.between(from: 100_000, to: 1_000_000) }
    departure_date { Faker::Date.forward(days: 30) }
    departure_time { Faker::Time.forward(days: 30, period: :evening) }
  end
end
