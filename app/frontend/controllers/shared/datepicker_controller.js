import { Controller } from '@hotwired/stimulus';
import flatpickr from 'flatpickr';

import 'flatpickr/dist/flatpickr.css';

export default class extends Controller {
  static targets = ['input'];

  connect() {
    flatpickr(this.inputTarget, {
      dateFormat: 'd/m/Y',
    });
  }

  focusInput() {
    this.inputTarget.focus();
  }
}
