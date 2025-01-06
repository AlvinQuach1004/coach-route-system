FactoryBot.define do
  factory :stop do
    route
    location
    stop_order { 1 }
    time_range { 1 }
  end
end
