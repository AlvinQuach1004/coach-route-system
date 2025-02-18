schedules = Schedule.includes(:coach, :tickets, route: :stops).all
users = User.all

50.times do
  schedule = schedules.sample
  user = users.sample
  coach = schedule.coach
  route = schedule.route

  next unless route.present? && route.stops.any?

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

  booked_seats = schedule.tickets.pluck(:seat_number).to_set

  available_seats = []

  ['A', 'B'].each do |row|
    seat_range.each do |num|
      seat = "#{row}#{num}"
      available_seats << seat unless booked_seats.include?(seat)
    end
  end

  rand(1..[available_seats.size, 3].min).times do
    break if available_seats.empty?

    seat_number = available_seats.sample

    next unless schedule.seat_available?(seat_number)

    booking.tickets.create!(
      schedule: schedule,
      seat_number: seat_number,
      status: Ticket::Status::PAID,
      paid_amount: schedule.price
    )

    booked_seats.add(seat_number)
    available_seats.delete(seat_number)
  end
end
