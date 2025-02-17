import { showToast } from './toast';
import * as Sentry from '@sentry/browser';

function initializeProfileEditor() {
  document.querySelectorAll('.inline-edit-field').forEach((field) => {
    const display = field.querySelector('.display-view');
    const form = field.querySelector('.edit-form');
    const input = field.querySelector('.edit-input');
    const editBtn = field.querySelector('.edit-button');
    const saveBtn = field.querySelector('.save-button');
    const cancelBtn = field.querySelector('.cancel-button');

    // Show edit form
    editBtn.addEventListener('click', () => {
      try {
        display.classList.add('hidden');
        form.classList.remove('hidden');
        input.focus();
      } catch (error) {
        Sentry.captureException(error);
        console.error('Error showing edit form:', error);
      }
    });

    // Cancel edit
    cancelBtn.addEventListener('click', () => {
      try {
        input.value = display.textContent.trim();
        display.classList.remove('hidden');
        form.classList.add('hidden');
      } catch (error) {
        Sentry.captureException(error);
      }
    });

    // Save changes
    saveBtn.addEventListener('click', (e) => {
      e.preventDefault();
      const formElement = field.querySelector('form');
      const fieldName = input.name.split('[')[1].split(']')[0];

      // Show loading state
      const originalSaveBtnContent = saveBtn.innerHTML;
      saveBtn.innerHTML = `
        <svg class="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
      `;

      fetch(formElement.action, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector("[name='csrf-token']").content,
        },
        body: JSON.stringify({
          user: {
            [fieldName]: input.value,
          },
        }),
      })
        .then((response) => response.json())
        .then((data) => {
          try {
            // Handle both flash messages and toast notifications
            if (data.html) {
              // Process flash messages from the partial
              const tempDiv = document.createElement('div');
              tempDiv.innerHTML = data.html;
              const flashElement = tempDiv.firstElementChild;

              if (flashElement) {
                const type = flashElement.dataset.flashType;
                const message = flashElement.dataset.flashMessage;
                showToast(message, type);
              }
            }

            if (data.success) {
              display.textContent = data.new_value;
              display.classList.remove('hidden');
              form.classList.add('hidden');
            }
          } catch (error) {
            Sentry.captureException(error);
          }
        })
        .catch((error) => {
          Sentry.captureException(error);
          showToast('An error occurred while saving changes', 'alert');
        })
        .finally(() => {
          saveBtn.innerHTML = originalSaveBtnContent;
        });
    });
  });
}

document.addEventListener('DOMContentLoaded', initializeProfileEditor);

export { initializeProfileEditor };
