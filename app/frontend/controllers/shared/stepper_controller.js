import { Controller } from '@hotwired/stimulus';
import { showToast } from './toast';
import * as Sentry from '@sentry/browser'; // Import Sentry

export default class extends Controller {
  static targets = ['progress', 'prev', 'next', 'progressContainer', 'stepTab', 'circleStep'];

  static values = {
    availableSeats: Number,
    selectedSeats: { type: Array, default: [] },
  };

  connect() {
    this.currentActive = 1;
    this.update();

    this.element.addEventListener('seats-updated', (event) => {
      this.selectedSeatsValue = event.detail.selectedSeats;
    });
  }

  next() {
    try {
      // Check conditions before proceeding to next step
      if (!this.canProceedToNextStep()) {
        return;
      }

      this.currentActive++;
      if (this.currentActive > this.circleStepTargets.length) {
        this.currentActive = this.circleStepTargets.length;
      }
      this.update();
    } catch (error) {
      Sentry.captureException(error); // Capture any error with Sentry
    }
  }

  canProceedToNextStep() {
    try {
      // If we're on step 1 and trying to go to step 2
      if (this.currentActive === 1) {
        if (this.availableSeatsValue <= 0) {
          showToast('This schedule is fully booked. Please choose another schedule.', 'alert');
          return false;
        }

        if (!this.selectedSeatsValue || this.selectedSeatsValue.length === 0) {
          console.log(this.selectedSeatsValue);
          showToast('Please select at least one seat to continue.', 'alert');
          return false;
        }
      }

      return true;
    } catch (error) {
      Sentry.captureException(error); // Capture any error with Sentry
      return false;
    }
  }

  prev() {
    try {
      this.currentActive--;
      if (this.currentActive < 1) {
        this.currentActive = 1;
      }
      this.update();
    } catch (error) {
      Sentry.captureException(error);
    }
  }

  update() {
    try {
      this.circleStepTargets.forEach((circle, idx) => {
        circle.classList.toggle('active', idx < this.currentActive);
      });

      // Update progress bar
      const progressWidth = ((this.currentActive - 1) / (this.circleStepTargets.length - 1)) * 100;
      this.progressTarget.style.width = `${progressWidth}%`;

      // Update step tabs visibility
      this.stepTabTargets.forEach((step, idx) => {
        step.classList.toggle('hidden', idx !== this.currentActive - 1);
      });

      // Enable prev when current active = 1
      this.prevTarget.disabled = this.currentActive === 1;
      this.nextTarget.disabled = this.currentActive === this.circleStepTargets.length;

      this.nextTarget.classList.toggle('hidden', this.currentActive === 3);
    } catch (error) {
      Sentry.captureException(error); // Capture any error with Sentry
    }
  }
}
