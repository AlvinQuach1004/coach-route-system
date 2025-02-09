class ApplicationNotifier < Noticed::Event
  # deliver_by :database
  # deliver_by :action_cable,
  #   channel: 'Noticed::NotificationChannel',
  #   stream: -> { recipient },
  #   message: -> {
  #     {
  #       html: ApplicationController.renderer.render(
  #         partial: 'notifications/notification',
  #         locals: { notification: record },
  #         layout: false
  #       ),
  #       count: recipient.notifications.unread.count
  #     }
  #   }
end
