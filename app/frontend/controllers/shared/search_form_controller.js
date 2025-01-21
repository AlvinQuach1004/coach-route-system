import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = [];

  submit() {
    // Add a small delay to prevent too many requests while typing
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, 300);
  }
}
