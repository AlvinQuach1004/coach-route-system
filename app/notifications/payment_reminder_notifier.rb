class PaymentReminderNotifier < ApplicationNotifier
  deliver_by :email do |config|
    config.mailer = 'NotificationMailer'
    config.method = :payment_reminder_notification
    config.params = -> { { booking: params[:booking], schedule: params[:schedule] } }
  end
end
