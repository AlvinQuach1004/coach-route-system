import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input', 'results'];

  fetchResults() {
    const query = this.inputTarget.value.trim();

    if (query.length < 1) {
      this.resultsTarget.classList.add('hidden');
      return;
    }

    fetch(`/locations/search?query=${query}`)
      .then((response) => response.json())
      .then((data) => {
        this.resultsTarget.innerHTML = '';

        // Add "Popular Locations" header
        const header = document.createElement('li');
        header.textContent = 'Popular address';
        header.classList.add('px-3', 'py-2', 'text-gray-500', 'text-sm');
        this.resultsTarget.appendChild(header);

        data.forEach((location) => {
          const item = document.createElement('li');
          item.textContent = location.name;
          item.classList.add('cursor-pointer', 'p-3', 'hover:bg-gray-100');
          item.addEventListener('click', () => this.selectLocation(location.name));

          this.resultsTarget.appendChild(item);
        });

        this.resultsTarget.classList.remove('hidden');
      });
  }

  selectLocation(name) {
    this.inputTarget.value = name;
    this.resultsTarget.classList.add('hidden');
  }
}
