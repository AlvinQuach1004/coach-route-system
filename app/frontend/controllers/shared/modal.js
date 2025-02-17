import * as Sentry from '@sentry/browser';

document.addEventListener('DOMContentLoaded', () => {
  try {
    document.addEventListener('click', (event) => {
      try {
        const openButton = event.target.closest('.modal-open-button');
        if (openButton) {
          event.preventDefault();

          const modalId = openButton.dataset.modalId;
          const modal = document.querySelector(`dialog.modal#${modalId}`);

          if (modal) {
            // Close any open modals
            document.querySelectorAll('dialog.modal[open]').forEach((m) => m.close());

            // Show the selected modal
            modal.showModal();
          }
        }
      } catch (error) {
        Sentry.captureException(error); // Capture error if any
      }
    });

    document.addEventListener('click', (event) => {
      try {
        const closeButton = event.target.closest('.modal-close-button');
        if (closeButton) {
          event.preventDefault();

          // Find the parent modal and close it
          const modal = closeButton.closest('dialog.modal');
          if (modal) {
            modal.close();
          }
        }
      } catch (error) {
        Sentry.captureException(error); // Capture error if any
      }
    });

    // Delegate click event to close modal when clicking outside modal-box
    document.addEventListener('click', (event) => {
      try {
        const modal = event.target.closest('dialog.modal');
        if (modal) {
          const modalBox = modal.querySelector('.modal-box');
          if (modalBox && !modalBox.contains(event.target)) {
            modal.close();
          }
        }
      } catch (error) {
        Sentry.captureException(error); // Capture error if any
      }
    });
  } catch (error) {
    Sentry.captureException(error); // Capture error if any during DOMContentLoaded
  }
});
