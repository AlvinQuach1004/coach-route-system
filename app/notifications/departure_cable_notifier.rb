class DepartureCableNotifier < Noticed::Event
  deliver_by :action_cable do |config|
    config.channel = 'Noticed::NotificationChannel'
    config.stream = -> { recipient }
    config.message = -> {
      {
        id: id,
        type: 'departure_notification_cable',
        schedule: params[:schedule].as_json(include: { route: { include: [:start_location, :end_location] } }),
        coach: params[:coach],
        user_id: recipient.id
      }
    }
  end
end
