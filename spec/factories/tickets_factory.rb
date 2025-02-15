FactoryBot.define do
  factory :ticket do
    booking
    schedule
    paid_amount { Faker::Number.between(from: 100_000, to: 1_000_000) }
    status { %w[booked paid cancelled].sample }

    seat_number do
      seat_ranges = schedule.seat_rows_by_type
      upper_seats = seat_ranges[:upper].to_a
      lower_seats = seat_ranges[:lower].to_a
      seat_row = (upper_seats + lower_seats).sample
      "#{%w[A B].sample}#{seat_row}"
    end
  end
end
