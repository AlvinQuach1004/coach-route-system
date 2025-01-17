import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['filter'];

  connect() {
    this.filterTargets.forEach((element) => {
      element.addEventListener('change', this.submitForm.bind(this));
    });
  }

  filter(event) {
    if (event.target.dataset.filterIgnore) return;
  }

  submitForm() {
    this.element.requestSubmit();
  }
}
