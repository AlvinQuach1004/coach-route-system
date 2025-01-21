import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    userId: String,
  };

  connect() {
    // Attach event listener to dynamically populate user ID
    document.querySelectorAll('[data-modal-toggle]').forEach((button) => {
      button.addEventListener('click', (e) => {
        const userId = e.currentTarget.dataset.userId;
        this.userIdValue = userId;
      });
    });
  }

  confirm() {
    if (this.userIdValue) {
      const token = document.querySelector('meta[name="csrf-token"]').content;
      fetch(`/admin/users/${this.userIdValue}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': token,
          'Content-Type': 'application/json',
        },
      }).then((response) => {
        if (response.ok) {
          window.location.reload(); // Reload page to reflect changes
        } else {
          alert('Failed to delete user.');
        }
      });
    }
  }
}
