import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["dialog"]
  static values = {
    id: String
  }

  connect() {
    // Ensure modal is initially closed
    this.dialogTarget.close();
  }

  show() {
    this.dialogTarget.showModal();
  }

  hide() {
    this.dialogTarget.close();
  }

  clickOutside(event) {
    if (event.target === this.dialogTarget) {
      this.hide(event)
    }
  }
}
