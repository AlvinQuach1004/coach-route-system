import { Controller } from '@hotwired/stimulus';
import { loadStripe } from '@stripe/stripe-js';

export default class extends Controller {
  static targets = ['paymentMethodInput', 'submitButton'];
  static values = {
    key: String,
    amount: Number,
  };

  connect() {
    this.initializeStripe();
  }

  async initializeStripe() {
    this.stripe = await loadStripe(this.keyValue);
  }

  updatePaymentMethod(event) {
    const method = event.target.value;
    // Update hidden payment method field if it exists
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
      // Disable submit button to prevent double submission
      this.submitButtonTarget.disabled = true;

      // Create checkout session
      const response = await fetch('/payments', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        },
        credentials: 'same-origin',
        body: JSON.stringify({
          booking: {
            start_stop_id: form.querySelector('[name="booking[start_stop_id]"]').value,
            end_stop_id: form.querySelector('[name="booking[end_stop_id]"]').value,
          },
          schedule_id: form.querySelector('[name="schedule_id"]').value,
          selected_seats: form.querySelector('[name="booking[selected_seats]"]').value,
        }),
      });

      const { session_id: sessionId } = await response.json();

      const result = await this.stripe.redirectToCheckout({
        sessionId,
      });

      if (result.error) {
        console.error('Payment failed:', result.error);
        this.submitButtonTarget.disabled = false;
      }
    } catch (error) {
      console.error('Error processing payment:', error);
      this.submitButtonTarget.disabled = false;
    }
  }
}
