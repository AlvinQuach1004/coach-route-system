class PaymentReminderCableNotifier < Noticed::Event
  deliver_by :action_cable do |config|
    config.channel = 'Noticed::NotificationChannel'
    config.stream = -> { recipient }
    config.message = -> {
      {
        id: id,
        type: 'payment_reminder_notification_cable',
        booking: params[:booking].as_json(
          include: {
            tickets: {},
            start_stop: { include: :location },
            end_stop: { include: :location }
          }
        ),
        schedule: params[:schedule].as_json(include: { route: { include: [:start_location, :end_location] } }),
        user_id: recipient.id
      }
    }
  end
end
