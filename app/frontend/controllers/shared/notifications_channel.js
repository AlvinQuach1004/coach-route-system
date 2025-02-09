import { createConsumer } from '@rails/actioncable';
import { mark_as_read_notification_path } from './routes';

const consumer = createConsumer();

const formatDate = (dateString) => {
  const date = new Date(dateString);
  const day = String(date.getDate()).padStart(2, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const year = date.getFullYear();
  return `${day}/${month}/${year}`;
};

const formatTime = (timeString) => {
  const date = new Date(timeString);
  return date.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit', hour12: false });
};

consumer.subscriptions.create('Noticed::NotificationChannel', {
  connected() {
    console.log('Connected to NotificationChannel');
  },
  received(data) {
    this.prependNotification(data);
    this.addMarkAllAsReadButton();
    this.updateUnreadCount(1);
  },
  prependNotification(data) {
    const notificationsList = document.querySelector('#notifications-list');
    if (notificationsList) {
      const newNotificationElement = this.createNotificationElement(data);
      notificationsList.insertBefore(newNotificationElement, notificationsList.firstChild);
    }
  },
  createNotificationElement(data) {
    const li = document.createElement('li');
    li.classList.add('notification-item', 'list-none', 'p-2', 'mb-1', 'bg-base-200');
    // console.log(data.schedule);

    const link = document.createElement('a');
    link.href = mark_as_read_notification_path(data.id);
    link.classList.add('flex', 'items-center', 'p-2', 'hover:bg-base-300', 'rounded-lg');
    link.dataset.turboMethod = 'post';
    link.dataset.notificationId = data.id;
    link.dataset.action = 'notifications#markAsRead';

    const flexDiv = document.createElement('div');
    flexDiv.classList.add('flex-1');

    const contentP = document.createElement('p');
    contentP.classList.add('text-sm');

    if (data.type === 'departure_notification_cable') {
      contentP.innerHTML = `
       Coach ${data.coach.license_plate} is departing.
       <br>
       <span class="text-xs text-base-content/60">
         Route: ${data.schedule.route.start_location.name} → ${data.schedule.route.end_location.name}
       </span>
       <br>
       <span class="text-xs text-base-content/60">
         Departure: ${formatDate(data.schedule.departure_date)} - ${formatTime(data.schedule.departure_time)}
       </span>
     `;
    } else if (data.type === 'payment_reminder_notification_cable') {
      contentP.innerHTML = `
      Payment reminder for booking #${data.booking.id} for schedule on ${formatDate(data.schedule.departure_date)} - ${formatTime(data.schedule.departure_time)}
      <br>
      <span class="text-xs text-base-content/60">
        Amount Due: ${this.formatCurrency(this.sumPaidAmount(data.booking.tickets))}
      </span>
      <br>
      <span class="text-xs text-base-content/60">
        Route: ${data.schedule.route.start_location.name} → ${data.schedule.route.end_location.name}
      </span>
      <br>
      <span class="text-xs text-base-content/60 font-semibold">Your Tickets:</span>
      <ul class="list-disc list-inside text-xs">
        ${data.booking.tickets
          .map(
            (ticket) => `
          <li>Seat #${ticket.seat_number} - ${this.formatCurrency(ticket.paid_amount)}</li>
        `,
          )
          .join('')}
      </ul>
      `;
    }
    const timeP = document.createElement('p');
    timeP.classList.add('text-xs', 'mt-1', 'text-base-content/60');
    timeP.textContent = 'Just now';

    const unreadDot = document.createElement('div');
    unreadDot.classList.add('w-2', 'h-2', 'bg-primary', 'rounded-full', 'unread-indicator');

    flexDiv.appendChild(contentP);
    flexDiv.appendChild(timeP);
    link.appendChild(flexDiv);
    link.appendChild(unreadDot);

    li.appendChild(link);
    const notificationsList = document.querySelector('#notifications-list');
    if (notificationsList.children.length > 0) {
      const divider = document.createElement('div');
      divider.classList.add('divider', 'my-0');
      notificationsList.insertBefore(divider, notificationsList.firstChild);
    }
    const noNotificationText = document.querySelector('.no-notifications-text');
    if (noNotificationText) noNotificationText.remove();

    return li;
  },
  sumPaidAmount(tickets) {
    return Number(tickets.reduce((sum, ticket) => sum + (Number(ticket.paid_amount) || 0), 0));
  },
  formatCurrency(amount) {
    const num = Number(amount);
    return `${num.toLocaleString('vi-VN')} VND`;
  },
  addMarkAllAsReadButton() {
    let markAllButton = document.querySelector('.mark-as-all-read-btn');

    if (!markAllButton) {
      const header = document.querySelector('.menu-title'); // Header của dropdown
      if (header) {
        markAllButton = document.createElement('button');
        markAllButton.classList.add('mark-as-all-read-btn', 'btn', 'btn-ghost', 'btn-xs');
        markAllButton.textContent = 'Mark all as read';

        markAllButton.setAttribute('data-action', 'notifications#markAllAsRead');

        // Append the button
        header.appendChild(markAllButton);
      }
    }
  },
  updateUnreadCount(increment) {
    let badgeContainer = document.querySelector('#notifications-badge');

    if (!badgeContainer) {
      const indicator = document.querySelector('.indicator');
      if (indicator) {
        badgeContainer = document.createElement('div');
        badgeContainer.id = 'notifications-badge';
        indicator.appendChild(badgeContainer);
      }
    }

    let badgeSpan = badgeContainer.querySelector('.badge-notifications-count');

    if (!badgeSpan) {
      badgeSpan = document.createElement('span');
      badgeSpan.classList.add('badge', 'badge-primary', 'badge-sm', 'indicator-item', 'badge-notifications-count');
      badgeContainer.appendChild(badgeSpan);
    }

    let currentCount = parseInt(badgeSpan.textContent) || 0;
    let newCount = currentCount + increment;

    if (newCount > 0) {
      badgeSpan.textContent = newCount;
    } else {
      badgeSpan.textContent = '0';
      badgeSpan.classList.add('hidden');
    }
  },
});
