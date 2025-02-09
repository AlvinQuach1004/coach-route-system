import { Controller } from '@hotwired/stimulus';
import { mark_all_as_read_notifications_path, mark_as_read_notification_path } from './routes';

export default class extends Controller {
  static targets = ['dropdown', 'content'];

  toggleDropdown() {
    this.contentTarget.classList.toggle('hidden');
  }

  markAsRead(event) {
    event.preventDefault();

    const notificationItem = event.currentTarget.closest('.notification-item');
    const markAsAllReadBtn = document.querySelector('.mark-as-all-read-btn');
    notificationItem.classList.remove('bg-base-200');

    const unreadIndicator = notificationItem.querySelector('.unread-indicator');
    if (unreadIndicator) {
      unreadIndicator.remove();

      const badge = document.querySelector('#notifications-badge .badge-notifications-count');
      if (badge) {
        let currentCount = parseInt(badge.textContent) || 0;
        let newCount = currentCount - 1;

        if (newCount > 0) {
          badge.textContent = newCount;
        } else {
          badge.textContent = '0';
          badge.remove();
          markAsAllReadBtn?.remove();
        }
      }
    }

    const notificationId = event.currentTarget.dataset.notificationId;
    fetch(mark_as_read_notification_path(notificationId), {
      method: 'POST',
      headers: {
        Accept: 'text/vnd.turbo-stream.html',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
      },
    });
  }

  markAllAsRead(event) {
    event.preventDefault();

    // Immediately update UI
    this.element.querySelectorAll('.notification-item').forEach((item) => {
      item.classList.remove('bg-base-200');
      const unreadIndicator = item.querySelector('.unread-indicator');
      if (unreadIndicator) {
        unreadIndicator.remove();
      }
    });

    const badge = document.querySelector('#notifications-badge');
    if (badge) {
      badge.innerHTML = '';
      badge.remove();
    }

    fetch(mark_all_as_read_notifications_path(), {
      method: 'POST',
      headers: {
        Accept: 'text/vnd.turbo-stream.html',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
      },
    });
  }

  // Hide dropdown when clicking outside
  disconnect() {
    this.contentTarget.classList.add('hidden');
  }
}
