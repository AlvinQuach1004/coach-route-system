class NotificationMailer < ApplicationMailer
  helper :mailers

  def departure_notification
    @recipient = params[:recipient]
    @schedule = params[:schedule]
    @coach = params[:coach]
    @booking = params[:booking]

    mail(
      to: @recipient.email,
      subject: "Trip Reminder: Coach #{@coach.license_plate} departing tomorrow"
    )
  end

  def payment_reminder_notification
    @recipient = params[:recipient]
    @booking = params[:booking]
    @schedule = params[:schedule]

    mail(
      to: @recipient.email,
      subject: "Payment Reminder for Tomorrow's Trip"
    )
  end

  def cancel_booking_notification
    @recipient = params[:recipient]
    @schedule = params[:schedule]

    mail(
      to: @recipient.email,
      subject: 'Booking Cancellation Notice'
    )
  end
end
