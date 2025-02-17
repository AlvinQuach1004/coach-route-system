import { Controller } from '@hotwired/stimulus';
import { showToast } from './toast';

export default class extends Controller {
  static targets = ['form'];

  connect() {
    this.handleFlashMessages();
  }

  handleFlashMessages() {
    try {
      const flashContainer = document.getElementById('flash-messages');
      if (!flashContainer) return;

      const flashMessage = flashContainer.querySelector('[data-flash-message]');
      if (flashMessage) {
        const type = flashMessage.dataset.flashType;
        const message = flashMessage.dataset.flashMessage;

        showToast(message, type);

        flashMessage.remove();
      }
    } catch (error) {
      Sentry.captureException(error);
    }
  }
}
