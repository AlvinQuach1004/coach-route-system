class DepartureNotifier < Noticed::Event
  deliver_by :email do |config|
    config.mailer = 'NotificationMailer'
    config.method = :departure_notification
    config.params = -> { { schedule: params[:schedule], coach: params[:coach], booking: params[:booking] } }
  end
end
