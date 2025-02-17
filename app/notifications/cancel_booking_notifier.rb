class CancelBookingNotifier < Noticed::Event
  deliver_by :email do |config|
    config.mailer = 'NotificationMailer'
    config.method = :cancel_booking_notification
    config.params = -> { { booking: params[:booking], schedule: params[:schedule] } }
  end
end
