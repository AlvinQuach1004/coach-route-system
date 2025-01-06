FactoryBot.define do
  factory :schedule do
    route
    coach
    departure_date { Faker::Date.forward(days: 30) }
    departure_time { Faker::Time.forward(days: 30, period: :evening) }
  end
end
