class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!
    @notifications = current_user.notifications.order(created_at: :desc).limit(20)
    @unread_count = current_user.notifications.unread.where(type: ['DepartureCableNotifier::Notification', 'PaymentReminderCableNotifier::Notification']).count

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "notification_#{@notification.id}",
            partial: 'notifications/notification',
            locals: { notification: @notification }
          ),
          turbo_stream.replace(
            'notifications_dropdown',
            partial: 'shared/notifications',
            locals: { notifications: @notifications, unread_count: @unread_count }
          )
        ]
      end
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
    @notifications = current_user.notifications.order(created_at: :desc).limit(20)
    @unread_count = 0

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          'notifications_dropdown',
          partial: 'shared/notifications',
          locals: { notifications: @notifications, unread_count: @unread_count }
        )
      end
    end
  end
end
