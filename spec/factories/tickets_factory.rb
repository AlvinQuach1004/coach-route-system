FactoryBot.define do
  factory :ticket do
    booking
    schedule
    price { 9.99 }
    status { 'booked' }
    seat_number { 'MyString' }
  end
end
