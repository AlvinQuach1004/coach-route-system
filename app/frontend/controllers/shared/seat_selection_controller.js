import { Controller } from '@hotwired/stimulus';

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
    console.log('Controller connected');
    console.log('Price Value:', this.priceValue);
    this.selectedSeats = [];
    this.initializeSeats();
    this.updateSummary();
  }

  initializeSeats() {
    this.seatTargets.forEach((seat) => {
      const seatStatus = seat.dataset.status;
      if (seatStatus === 'chosen') {
        this.markSeatAsChosen(seat);
      } else {
        this.markSeatAsAvailable(seat);
      }
    });
  }

  toggleSeat(event) {
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
  }

  selectSeat(seat, seatId) {
    this.selectedSeats.push(seatId);
    console.log(this.selectedSeats);
    seat.classList.remove('bg-white');
    seat.classList.add('bg-green-400');
    seat.dataset.status = 'selected';
  }

  unselectSeat(seat, seatId) {
    const index = this.selectedSeats.indexOf(seatId);
    if (index > -1) {
      this.selectedSeats.splice(index, 1);
    }
    seat.classList.remove('bg-green-400');
    seat.classList.add('bg-white');
    seat.dataset.status = 'available';
  }

  markSeatAsChosen(seat) {
    seat.classList.remove('bg-white', 'bg-green-400');
    seat.classList.add('bg-gray-400');
    seat.dataset.status = 'chosen';
  }

  markSeatAsAvailable(seat) {
    seat.classList.remove('bg-gray-400', 'bg-green-400');
    seat.classList.add('bg-white');
    seat.dataset.status = 'available';
  }

  updateSummary() {
    // Update selected seats display
    if (this.hasSelectedSeatsTarget) {
      const seatsText = this.selectedSeats.length > 0 
        ? this.selectedSeats.join(', ')
        : 'Chưa chọn ghế';
      this.selectedSeatsTarget.textContent = seatsText;
    }

    // Calculate and update total price
    const totalPrice = this.selectedSeats.length * this.priceValue;
    this.priceStep3Target.textContent = `${this.formatCurrency(this.priceValue)}₫`
    
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
  }

  submitForm(event) {
    if (this.selectedSeats.length === 0) {
      event.preventDefault();
      alert("Please select at least one seat");
      return;
    }
  }

  formatCurrency(amount) {
    return amount.toLocaleString('vi-VN');
  }
}
