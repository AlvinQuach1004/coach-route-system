import { Controller } from '@hotwired/stimulus';
import * as Sentry from '@sentry/browser';

export default class extends Controller {
  static targets = [
    'seat',
    'selectedSeats',
    'totalPrice',
    'totalQuantity',
    'totalPriceStep2',
    'priceStep3',
    'totalQuantityStep3',
    'totalPriceStep3',
    'selectedSeatsInput',
    'paymentMethod',
  ];

  static values = {
    price: Number,
    currentStep: { type: Number, default: 1 },
  };

  connect() {
    try {
      console.log('Controller connected');
      console.log('Price Value:', this.priceValue);
      this.selectedSeats = [];
      this.initializeSeats();
      this.updateSummary();
    } catch (error) {
      Sentry.captureException(error);
    }
  }

  initializeSeats() {
    try {
      this.seatTargets.forEach((seat) => {
        const seatStatus = seat.dataset.status;
        if (seatStatus === 'chosen') {
          this.markSeatAsChosen(seat);
        } else {
          this.markSeatAsAvailable(seat);
        }
      });
    } catch (error) {
      Sentry.captureException(error);
    }
  }

  toggleSeat(event) {
    try {
      const seat = event.currentTarget;
      const seatId = seat.dataset.id;
      const seatStatus = seat.dataset.status;
      console.log(seatStatus, seatId);

      if (seatStatus === 'chosen') {
        return;
      }

      if (seatStatus === 'selected') {
        this.unselectSeat(seat, seatId);
      } else if (seatStatus === 'available') {
        this.selectSeat(seat, seatId);
      }

      this.updateSummary();
    } catch (error) {
      Sentry.captureException(error);
    }
  }

  selectSeat(seat, seatId) {
    try {
      this.selectedSeats.push(seatId);
      console.log(this.selectedSeats);
      seat.classList.remove('bg-white');
      seat.classList.add('bg-green-400');
      seat.dataset.status = 'selected';

      const event = new CustomEvent('seats-updated', {
        detail: { selectedSeats: this.selectedSeats },
        bubbles: true,
      });
      this.element.dispatchEvent(event);
    } catch (error) {
      Sentry.captureException(error);
    }
  }

  unselectSeat(seat, seatId) {
    try {
      const index = this.selectedSeats.indexOf(seatId);
      if (index > -1) {
        this.selectedSeats.splice(index, 1);
      }
      seat.classList.remove('bg-green-400');
      seat.classList.add('bg-white');
      seat.dataset.status = 'available';
      const event = new CustomEvent('seats-updated', {
        detail: { selectedSeats: this.selectedSeats },
        bubbles: true,
      });
      this.element.dispatchEvent(event);
    } catch (error) {
      Sentry.captureException(error);
    }
  }

  markSeatAsChosen(seat) {
    try {
      seat.classList.remove('bg-white', 'bg-green-400');
      seat.classList.add('bg-gray-400');
      seat.dataset.status = 'chosen';
    } catch (error) {
      Sentry.captureException(error);
    }
  }

  markSeatAsAvailable(seat) {
    try {
      seat.classList.remove('bg-gray-400', 'bg-green-400');
      seat.classList.add('bg-white');
      seat.dataset.status = 'available';
    } catch (error) {
      Sentry.captureException(error);
    }
  }

  updateSummary() {
    try {
      // Update selected seats display
      if (this.hasSelectedSeatsTarget) {
        const seatsText = this.selectedSeats.length > 0 ? this.selectedSeats.join(', ') : 'Chưa chọn ghế';
        this.selectedSeatsTarget.textContent = seatsText;
      }

      // Calculate and update total price
      const totalPrice = this.selectedSeats.length * this.priceValue;
      this.priceStep3Target.textContent = `${this.formatCurrency(this.priceValue)}₫`;

      if (this.hasTotalPriceTarget) {
        this.totalPriceTarget.textContent = `${this.formatCurrency(totalPrice)}₫`;
        this.totalPriceStep2Target.textContent = `${this.formatCurrency(totalPrice)}₫`;
        this.totalPriceStep3Target.textContent = `${this.formatCurrency(totalPrice)}₫`;
      }

      // Update quantity displays if they exist
      const totalQuantity = this.selectedSeats.length;
      if (this.hasTotalQuantityTarget) {
        this.totalQuantityTarget.textContent = totalQuantity;
      }

      if (this.hasTotalQuantityStep3Target) {
        this.totalQuantityStep3Target.textContent = totalQuantity;
      }

      // Update hidden input for form submission
      if (this.hasSelectedSeatsInputTarget) {
        this.selectedSeatsInputTarget.value = JSON.stringify(this.selectedSeats);
      }
    } catch (error) {
      Sentry.captureException(error);
    }
  }

  submitForm(event) {
    try {
      if (this.selectedSeats.length === 0) {
        event.preventDefault();
        return;
      }
    } catch (error) {
      Sentry.captureException(error);
    }
  }

  formatCurrency(amount) {
    try {
      return amount.toLocaleString('vi-VN');
    } catch (error) {
      Sentry.captureException(error);
      return amount;
    }
  }
}
