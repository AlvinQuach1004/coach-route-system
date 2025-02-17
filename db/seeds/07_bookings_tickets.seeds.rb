schedules = Schedule.all
users = User.all

50.times do
  schedule = schedules.sample
  user = users.sample
  coach = schedule.coach
  route = schedule.route

  # Kiểm tra route có tồn tại không trước khi tạo booking
  next unless route.present? && route.stops.any?

  # Xác định start_stop và end_stop dựa trên route
  start_stop = route.stops.first
  end_stop = route.stops.last

  booking = user.bookings.create!(
    payment_method: Booking::PaymentMethod::STRIPE,
    payment_status: Booking::PaymentStatus::COMPLETED,
    start_stop: start_stop,
    end_stop: end_stop
  )

  seat_range = case coach.coach_type
               when Coach::Capacity::LIMOUSINE then 1..14
               when Coach::Capacity::ROOM then 1..16
               when Coach::Capacity::SLEEPER then 1..18
               else 1..20
               end

  rand(1..3).times do
    row = ['A', 'B'].sample
    seat_number = "#{row}#{Faker::Number.between(from: seat_range.min, to: seat_range.max)}"

    # Kiểm tra seat number có khả dụng không trước khi tạo vé
    next unless schedule.seat_available?(seat_number)
    booking.tickets.create!(
      schedule: schedule,
      seat_number: seat_number,
      status: Ticket::Status::PAID,
      paid_amount: schedule.price
    )
  end
end
