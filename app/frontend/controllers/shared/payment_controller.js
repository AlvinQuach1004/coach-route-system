import { Controller } from '@hotwired/stimulus';
import { loadStripe } from '@stripe/stripe-js';
import { bookings_path } from './routes';
import { showToast } from './toast';

export default class extends Controller {
  static targets = ['paymentMethodInput', 'submitButton'];
  static values = {
    amount: Number,
  };

  connect() {
    this.initializeStripe();
  }

  async initializeStripe() {
    this.stripe = await loadStripe(import.meta.env.VITE_STRIPE_PUBLISHABLE_KEY);
  }

  updatePaymentMethod(event) {
    const method = event.target.value;
    const paymentMethodField = document.querySelector('input[name="booking[payment_method]"]');
    if (paymentMethodField) {
      paymentMethodField.value = method;
    }
  }

  async processPayment(event) {
    event.preventDefault();
    event.stopPropagation();

    const form = event.target.closest('form');
    const selectedPaymentMethod = this.paymentMethodInputTargets.find((input) => input.checked).value;

    if (selectedPaymentMethod === 'stripe') {
      await this.handleStripePayment(form);
    } else {
      form.submit();
    }
  }

  async handleStripePayment(form) {
    try {
      this.submitButtonTarget.disabled = true;

      const startStopId =
        form.querySelector('[name="booking[start_stop_id]"]').value === ''
          ? form.querySelector('[name="booking[start_stop_id]"]').dataset.defaultValue
          : form.querySelector('[name="booking[start_stop_id]"]').value;
      const endStopId =
        form.querySelector('[name="booking[end_stop_id]"]').value === ''
          ? form.querySelector('[name="booking[end_stop_id]"]').dataset.defaultValue
          : form.querySelector('[name="booking[end_stop_id]"]').value;
      const ticketPrice = form.querySelector('[name="booking[ticket_price]"]').value;
      const pickupAddress = form.querySelector('[name="booking[pickup_address]"]').value || '';
      const dropoffAddress = form.querySelector('[name="booking[dropoff_address]"]').value || '';
      const departureDate = form.querySelector('[name="booking[departure_date]"]').value || '';
      const departureTime = form.querySelector('[name="booking[departure_time]"]').value || '';

      console.log('Start address:', startStopId);
      console.log('End address:', endStopId);

      const response = await fetch(bookings_path(), {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        },
        credentials: 'same-origin',
        body: JSON.stringify({
          booking: {
            start_stop_id: startStopId,
            end_stop_id: endStopId,
            selected_seats: form.querySelector('[name="booking[selected_seats]"]').value,
            ticket_price: ticketPrice,
            pickup_address: pickupAddress,
            dropoff_address: dropoffAddress,
            departure_date: departureDate,
            departure_time: departureTime,
          },
          schedule_id: form.querySelector('[name="schedule_id"]').value,
        }),
      });

      if (response.status === 422) {
        const errorData = await response.json();
        console.error('Booking error:', errorData);
        showToast(errorData.error, 'alert');
        this.submitButtonTarget.disabled = false;
        return;
      }

      if (!response.ok) {
        throw new Error(`Server error: ${response.status}`);
      }

      const { session_id: sessionId } = await response.json();
      const result = await this.stripe.redirectToCheckout({ sessionId });

      if (result.error) {
        console.error('Payment failed:', result.error);
        showToast(result.error.message || 'Thanh toán thất bại!', 'alert');
        this.submitButtonTarget.disabled = false;
      }
    } catch (error) {
      console.error('Error processing payment:', error);
      showToast(error.message || 'Đã xảy ra lỗi!', 'alert');
      this.submitButtonTarget.disabled = false;
    }
  }
}
