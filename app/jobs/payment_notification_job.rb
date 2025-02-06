class PaymentNotificationJob
  include Sidekiq::Job

  def perform # rubocop:disable Metrics/MethodLength
    tomorrow = Date.tomorrow
    schedules = Schedule.where(departure_date: tomorrow)

    schedules.each do |schedule|
      # Get unique bookings for this schedule with pending cash payments
      unique_bookings = Ticket.includes(
        booking: :user,
        schedule: [:route, :coach]
      ).joins(:booking)
        .where(
          schedule: schedule,
          bookings: {
            payment_method: Booking::PaymentMethod::CASH,
            payment_status: Booking::PaymentStatus::PENDING
          }
        ).select('DISTINCT ON (bookings.id) tickets.*')

      unique_bookings.each do |ticket|
        booking = ticket.booking
        user = booking.user
        route = schedule.route

        # Skip if notification already exists
        next if Notification.exists?(
          user: user,
          booking_id: booking.id,
          title: 'Payment Trip Reminder'
        )

        # Create notification for the user
        Notification.create!(
          user: user,
          booking_id: booking.id,
          title: 'Payment Trip Reminder',
          body: "Your trip from #{route.start_location.name} to #{route.end_location.name} " \
                'tomorrow requires payment completion. Please complete your payment before departure.',
          is_read: false
        )
      end
    end
  end
end
