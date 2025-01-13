import { registerControllers } from 'stimulus-vite-helpers';
import { Application } from '@hotwired/stimulus';
import 'flatpickr/dist/flatpickr.min.css'; // Import Flatpickr CSS
import flatpickr from 'flatpickr'; // Import Flatpickr JavaScript

const application = Application.start();

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

const controllers = import.meta.glob('./**/*_controller.js', { eager: true });

// Register Stimulus controllers
registerControllers(application, controllers);
// Datepicker format from flatpickr
document.addEventListener('turbo:load', () => {
  // Use turbo:load Turbo Drive enables partial page updates instead of full page reloads.
  // Datepicker logic
  const datepicker = document.getElementById('datepicker');
  const datepickerIcon = document.querySelector('.datepicker-icon');
  if (datepicker) {
    flatpickr(datepicker, {
      dateFormat: 'd/m/Y',
    });
  }
  if (datepickerIcon) {
    datepickerIcon.addEventListener('click', () => {
      datepicker.focus();
    });
  }

  const form = document.getElementById('filter-form');
  const filterElements = form.querySelectorAll('[data-filter]');
  filterElements.forEach((element) => {
    element.addEventListener('change', function () {
      form.submit();
    });
  });

  // Stepper logic for view details
  document.querySelectorAll('.progress-btn-container').forEach((card) => {
    const progress = card.querySelector('#progress');
    const prev = card.querySelector('#prev');
    const next = card.querySelector('#next');
    const progressContainer = card.querySelector('.progress-container');
    const circles = progressContainer.querySelectorAll('.circle-step');

    // Assuming you have steps inside the step-tab containers:
    const steps = card.querySelectorAll('.step-tab');

    let currentActive = 1; // Start at the first step

    next.addEventListener('click', () => {
      currentActive++;

      if (currentActive > circles.length) {
        currentActive = circles.length; // Prevent going beyond the last step
      }

      update(); // Update the stepper and switch content
    });

    prev.addEventListener('click', () => {
      currentActive--;

      if (currentActive < 1) {
        currentActive = 1; // Prevent going before the first step
      }
      update(); // Update the stepper
    });

    function update() {
      // Add 'active' class to circles that are less than or equal to the current step
      circles.forEach((circle, idx) => {
        if (idx < currentActive) {
          circle.classList.add('active');
        } else {
          circle.classList.remove('active');
        }
      });

      // Update the progress width dynamically
      const progressWidth = ((currentActive - 1) / (circles.length - 1)) * 100;
      progress.style.width = `${progressWidth}%`;

      // Show/hide steps
      steps.forEach((step, idx) => {
        if (idx === currentActive - 1) {
          step.classList.remove('hidden'); // Show the current step
        } else {
          step.classList.add('hidden'); // Hide the other steps
        }
      });

      // Disable/enable buttons based on the current step
      if (currentActive === 1) {
        prev.disabled = true; // Disable Prev button on the first step
      } else if (currentActive === circles.length) {
        next.disabled = true; // Disable Next button on the last step
      } else {
        prev.disabled = false;
        next.disabled = false;
      }

      // Hide both navigation buttons when on step 3
      if (currentActive === 3) {
        next.classList.add('hidden');
      } else {
        next.classList.remove('hidden');
      }
    }

    update();
  });
});

// Get page load (in case Turbo isn't enabled)
document.addEventListener('DOMContentLoaded', () => {
  // Carousel logic
  document.dispatchEvent(new Event('turbo:load'));
});
