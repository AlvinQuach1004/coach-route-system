import { Controller } from '@hotwired/stimulus';
import { showToast } from './toast';
import * as Sentry from '@sentry/browser';

export default class extends Controller {
  static values = {
    availableSeats: Number,
    dropdownOpen: { type: Boolean, default: false },
  };

  checkAvailability(event) {
    try {
      if (!this.dropdownOpenValue) {
        if (this.availableSeatsValue <= 0) {
          event.preventDefault();
          event.stopPropagation();
          showToast('This schedule is fully booked. Please choose another schedule.', 'alert');

          const button = event.currentTarget;
          button.disabled = true;
          button.classList.add('opacity-50', 'cursor-not-allowed');
        } else if (this.availableSeatsValue <= 5) {
          showToast(`Only ${this.availableSeatsValue} seats remaining!`, 'warning');
        }
      }
      this.dropdownOpenValue = !this.dropdownOpenValue;
    } catch (error) {
      // Log error to Sentry
      Sentry.captureException(error);
    }
  }
}
