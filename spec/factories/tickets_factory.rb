FactoryBot.define do
  factory :ticket do
    booking
    schedule
    price { Faker::Number.decimal(l_digits: 2) }
    status { ['booked', 'paid', 'cancelled'].sample }
    seat_number { Faker::String.random(length: 3) }
  end
end
