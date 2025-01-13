import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['container', 'slide'];

  connect() {
    this.currentPosition = 0;
    this.cardWidth = this.slideTargets[0].offsetWidth;
    this.totalCards = this.slideTargets.length;
    this.visibleCards = 4;
  }

  prev() {
    this.currentPosition += this.cardWidth;
    if (this.currentPosition > 0) {
      this.currentPosition = -(this.cardWidth * (this.totalCards - this.visibleCards));
    }
    this.updatePosition();
  }

  next() {
    this.currentPosition -= this.cardWidth;
    if (Math.abs(this.currentPosition) >= this.cardWidth * (this.totalCards - this.visibleCards + 1)) {
      this.currentPosition = 0;
    }
    this.updatePosition();
  }

  updatePosition() {
    this.containerTarget.style.transform = `translateX(${this.currentPosition}px)`;
  }
}
