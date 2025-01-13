// app/javascript/controllers/progress_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "progress",
    "prev",
    "next",
    "progressContainer",
    "stepTab",
    "circleStep",
  ];

  connect() {
    this.currentActive = 1; // Set initial active step
    this.update();
  }

  next() {
    this.currentActive++;
    if (this.currentActive > this.circleStepTargets.length) {
      this.currentActive = this.circleStepTargets.length;
    }
    this.update();
  }

  prev() {
    this.currentActive--;
    if (this.currentActive < 1) {
      this.currentActive = 1;
    }
    this.update();
  }

  update() {
    this.circleStepTargets.forEach((circle, idx) => {
      circle.classList.toggle("active", idx < this.currentActive);
    });

    // Update progress bar
    const progressWidth = ((this.currentActive - 1) / (this.circleStepTargets.length - 1)) * 100;
    this.progressTarget.style.width = `${progressWidth}%`;

    // Update step tabs visibility
    this.stepTabTargets.forEach((step, idx) => {
      step.classList.toggle("hidden", idx !== this.currentActive - 1);
    });

    // Enable prev when current active = 1
    this.prevTarget.disabled = this.currentActive === 1;
    this.nextTarget.disabled = this.currentActive === this.circleStepTargets.length;

    this.nextTarget.classList.toggle("hidden", this.currentActive === 3);
  }
}
