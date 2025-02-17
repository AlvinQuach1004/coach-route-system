class SendTomorrowNotificationsJob
  include Sidekiq::Job

  def perform # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    tomorrow = Date.tomorrow

    Schedule.includes(:coach, :route, tickets: { booking: :user })
      .where(departure_date: tomorrow)
      .find_each do |schedule|
      users_with_bookings = User.joins(bookings: :tickets)
        .where(tickets: { schedule_id: schedule.id })
        .select('users.*, bookings.id AS booking_id')
        .distinct

      users_with_bookings.each do |user|
        booking = Booking.includes(tickets: [:schedule]).find(user.booking_id)

        # Lưu dữ liệu booking vào Hash
        booking_data = {
          id: booking.id,
          user_id: booking.user_id,
          payment_status: booking.payment_status,
          start_stop: { location: { name: booking.start_stop.location.name } },
          end_stop: { location: { name: booking.end_stop.location.name } },
          tickets: booking.tickets.map do |ticket|
            {
              seat_number: ticket.seat_number,
              formatted_departure_date: ticket.formatted_departure_date,
              formatted_departure_time: ticket.formatted_departure_time,
              departure_date: ticket.departure_date,
              departure_time: ticket.departure_time,
              paid_amount: ticket.paid_amount
            }
          end
        }

        # Lưu dữ liệu schedule vào Hash
        schedule_data = {
          id: schedule.id,
          departure_date: schedule.departure_date,
          route: {
            start_location: { name: schedule.route.start_location.name },
            end_location: { name: schedule.route.end_location.name }
          }
        }

        # Lưu dữ liệu coach vào Hash
        coach_data = {
          id: schedule.coach.id,
          license_plate: schedule.coach.license_plate
        }

        DepartureNotifier.with(
          schedule: schedule_data,
          coach: coach_data,
          booking: booking_data
        ).deliver(user)

        DepartureCableNotifier.with(
          schedule: schedule_data,
          coach: coach_data,
          booking: booking_data
        ).deliver(user)
      end
    end
  end
end
