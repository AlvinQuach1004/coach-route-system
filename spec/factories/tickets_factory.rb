FactoryBot.define do
  factory :ticket do
    booking
    schedule
    price { Faker::Number.between(from: 100_000, to: 1_000_000) }
    status { ['booked', 'paid', 'cancelled'].sample }
    seat_number { Faker::String.random(length: 3).upcase }
  end
end
