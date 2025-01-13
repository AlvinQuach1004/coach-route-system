import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['departure', 'destination'];

  exchange(event) {
    event.preventDefault();

    // Swap the values of the departure and destination inputs
    const tempValue = this.departureTarget.value;
    this.departureTarget.value = this.destinationTarget.value;
    this.destinationTarget.value = tempValue;
  }
}
