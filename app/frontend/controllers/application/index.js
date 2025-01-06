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
  // Exchange button logic
  const departureInput = document.getElementById('departure');
  const destinationInput = document.getElementById('destination');
  const exchangeButton = document.getElementById('exchange-btn');

  if (exchangeButton) {
    exchangeButton.addEventListener('click', (e) => {
      e.preventDefault();
      const tempValue = departureInput.value;
      departureInput.value = destinationInput.value;
      destinationInput.value = tempValue;
    });
  }
  // Carousel logic
  const carousel = document.getElementById('carousel');
  const prevButton = document.getElementById('prev');
  const nextButton = document.getElementById('next');

  if (carousel && prevButton && nextButton) {
    const cardWidth = document.querySelector('.carousel-item').offsetWidth;
    const totalCards = document.querySelectorAll('.carousel-item').length;
    const visibleCards = 4; // Number of visible cards in front of the carousel
    let currentPosition = 0;

    prevButton.addEventListener('click', () => {
      currentPosition += cardWidth;
      if (currentPosition > 0) {
        currentPosition = -(cardWidth * (totalCards - visibleCards));
      }
      carousel.style.transform = `translateX(${currentPosition}px)`;
    });

    nextButton.addEventListener('click', () => {
      currentPosition -= cardWidth;
      if (Math.abs(currentPosition) >= cardWidth * (totalCards - visibleCards + 1)) {
        currentPosition = 0;
      }
      carousel.style.transform = `translateX(${currentPosition}px)`;
    });
  }
});
// Get page load (in case Turbo isn't enabled)
document.addEventListener('DOMContentLoaded', () => {
  document.dispatchEvent(new Event('turbo:load'));
});
