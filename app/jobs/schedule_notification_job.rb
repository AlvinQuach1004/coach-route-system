class ScheduleNotificationJob
  include Sidekiq::Job

  def perform
    tomorrow = Date.tomorrow
    schedules = Schedule.where(departure_date: tomorrow)

    schedules.each do |schedule|
      # Get unique bookings for this schedule
      # Using distinct on booking_id to avoid duplicate notifications
      unique_bookings = Ticket.includes(
        booking: :user,
        schedule: [:route, :coach]
      ).where(
        schedule: schedule
      ).select('DISTINCT ON (booking_id) tickets.*')

      unique_bookings.each do |ticket|
        booking = ticket.booking
        user = booking.user
        coach = schedule.coach
        route = schedule.route

        next if Notification.exists?(
          user: user,
          booking_id: booking.id,
          title: 'Upcoming Trip Reminder'
        )

        Notification.create!(
          user: user,
          booking_id: booking.id,
          title: 'Upcoming Trip Reminder',
          body: "Your trip from #{route.start_location.name} to #{route.end_location.name} " \
                "is tomorrow. Coach License Plate: #{coach.license_plate}",
          is_read: false
        )
      end
    end
  end
end
