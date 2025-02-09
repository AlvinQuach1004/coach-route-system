class SendTomorrowNotificationsJob
  include Sidekiq::Job

  def perform # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    tomorrow = Date.tomorrow

    # Send departure notifications
    Schedule.includes(:coach, :route, tickets: { booking: :user })
      .where(departure_date: tomorrow)
      .find_each do |schedule|
      users = User.joins(bookings: :tickets)
        .where(tickets: { schedule_id: schedule.id })
        .distinct

      users.each do |user|
        DepartureNotifier.with(
          schedule: schedule,
          coach: schedule.coach
        ).deliver(user)
        DepartureCableNotifier.with(
          schedule: schedule,
          coach: schedule.coach
        ).deliver(user)
      end
    end

    # Send payment reminders for unpaid bookings
    Booking.includes(tickets: { schedule: [:route, :coach] })
      .joins(:tickets)
      .where(tickets: { schedule_id: Schedule.where(departure_date: tomorrow).select(:id) })
      .where(payment_status: 'pending')
      .distinct
      .find_each do |booking|
      PaymentReminderNotifier.with(
        booking: booking,
        schedule: booking.tickets.first.schedule
      ).deliver(booking.user)
      PaymentReminderCableNotifier.with(
        booking: booking,
        schedule: booking.tickets.first.schedule
      ).deliver(booking.user)s
    end
  end
end
