FactoryBot.define do
  factory :schedule do
    route
    coach
    departure_date { '2025-12-12' }
    departure_time { '22:28:48' }
  end
end
