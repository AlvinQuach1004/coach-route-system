import { Controller } from '@hotwired/stimulus';
import Toastify from 'toastify-js';

export default class extends Controller {
  static values = {
    type: String,
    message: String,
  };

  connect() {
    if (this.hasMessageValue) {
      this.showToast();
      console.log(this.toastClasses());
    }
  }

  showToast() {
    const toastConfig = {
      text: this.messageValue,
      duration: 2000,
      gravity: 'top',
      position: 'right',
      escapeMarkup: false,
      className: this.toastClasses(),
      style: this.toastStyle(),
      stopOnFocus: true,
    };
    Toastify(toastConfig).showToast();
  }

  toastStyle() {
    return {
      padding: '0.5rem 1rem',
      borderRadius: '0.5rem',
      boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1)',
    };
  }

  toastClasses() {
    const baseClasses = 'rounded-lg shadow-lg px-4 py-2 text-white';
    switch (this.typeValue) {
      case 'success':
        return `${baseClasses} bg-green-300`;
      case 'error':
        return `${baseClasses} bg-red-300`;
      case 'warning':
        return `${baseClasses} bg-yellow-300 text-black`;
      case 'info':
        return `${baseClasses} bg-blue-300`;
      default:
        return `${baseClasses} bg-gray-300`;
    }
  }
}
