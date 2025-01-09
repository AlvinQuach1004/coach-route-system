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

  const form = document.getElementById('filter-form');
  const filterElements = form.querySelectorAll('[data-filter]');
  filterElements.forEach((element) => {
    element.addEventListener('change', function () {
      form.submit();
    });
  });

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

  // Handle tab switching
  const tabList = document.querySelectorAll('.tab');
  tabList.forEach((tab) => {
    tab.addEventListener('click', (e) => {
      tabList.forEach((t) => t.classList.remove('tab-active')); // Remove active class from all tabs except for the current one
      e.target.classList.add('tab-active'); // Add active class to clicked tab
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
  // Seat selection logic
});

document.querySelectorAll('.dropdown-book-container').forEach((card) => {
  const seats = card.querySelectorAll('.seat');
  console.log(seats.length);

  const chosenSeats = ['A1', 'A5', 'A7']; // Example chosen seats
  let selectedSeats = []; // To track seats selected by the current user

  seats.forEach((seat) => {
    const seatId = seat.getAttribute('data-id');
    
    // Cannot choose gray seat (chosen)
    if (chosenSeats.includes(seatId)) {
      seat.classList.remove('bg-white');
      seat.classList.add('bg-gray-400');
      seat.setAttribute('data-status', 'chosen');
    } else {
      seat.classList.add('bg-white');
      seat.setAttribute('data-status', 'available');
    }

    // Add click event listener for toggle functionality
    seat.addEventListener('click', function () {
      const seatStatus = seat.getAttribute('data-status');

      // Only allow toggling for available seats
      if (seatStatus === 'selected') {
        if (seat.classList.contains('bg-green-400')) {
          const index = selectedSeats.indexOf(seatId);
          if (index > -1) selectedSeats.splice(index, 1); // Remove seatId from array
          seat.classList.remove('bg-green-400');
          seat.classList.add('bg-white');
          seat.setAttribute('data-status', 'available');
        }
      } else if (seatStatus === 'available') {
        selectedSeats.push(seatId);
        seat.classList.remove('bg-white');
        seat.classList.add('bg-green-400');
        seat.setAttribute('data-status', 'selected');
      }

      const selectedSeatsCount = selectedSeats.length;
      const selectedSeatsDisplay = card.querySelector('#selected-seats');
      const totalPriceDisplay = card.querySelector('#total-price');
      console.log(selectedSeats);
      // document.querySelector('input[name="booking[seat_number]"]').value = seatId;

      // Display the number of selected seats and the total price
      selectedSeatsDisplay.textContent = selectedSeats.join(', ') || '';
      totalPriceDisplay.textContent = `${selectedSeatsCount * 270000}₫`;
    });
  });
});

// Get page load (in case Turbo isn't enabled)
document.addEventListener('DOMContentLoaded', () => {
  document.dispatchEvent(new Event('turbo:load'));
});
