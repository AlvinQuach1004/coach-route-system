import Toastify from 'toastify-js';

const TOAST_TYPES = {
  notice: {
    background: '#3b82f6', // blue-500
    duration: 3000,
  },
  alert: {
    background: '#ef4444', // red-500
    duration: 3000,
  },
  warning: {
    background: '#f59e0b', // amber-500
    duration: 3000,
  },
  success: {
    background: '#22c55e', // green-500
    duration: 3000,
  },
};

const showToast = (message, type = 'notice') => {
  const options = TOAST_TYPES[type] || TOAST_TYPES.notice;

  Toastify({
    text: message,
    duration: options.duration,
    gravity: 'top',
    position: 'right',
    stopOnFocus: true,
    className: 'rounded-lg',
    style: {
      background: options.background,
    },
    onClick: function () {},
  }).showToast();
};

document.addEventListener('DOMContentLoaded', () => {
  const flashMessages = document.querySelectorAll('[data-flash-type]');

  flashMessages.forEach((flash) => {
    const type = flash.dataset.flashType;
    const message = flash.dataset.flashMessage;

    showToast(message, type);
  });
});
