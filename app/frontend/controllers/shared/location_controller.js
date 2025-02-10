import { Controller } from "@hotwired/stimulus";
import { Modal } from "daisyui";

export default class extends Controller {
  static targets = ["modal", "searchInput", "autocompleteResults", "map"];

  connect() {
    this.modal = new Modal(this.modalTarget);
    this.initializeAutocomplete();
  }

  openPickupModal() {
    this.modal.show();
    this.initializeMap();
  }

  closeModal() {
    this.modal.hide();
  }

  confirmPickupLocation() {
    const selectedLocation = this.selectedLocation;
    console.log("Selected Location:", selectedLocation);
    this.modal.hide();
  }

  initializeAutocomplete() {
    const searchInput = this.searchInputTarget;
    const autocompleteResults = this.autocompleteResultsTarget;

    searchInput.addEventListener("input", async (event) => {
      const query = event.target.value;

      if (query.length > 2) {
        // Fetch autocomplete results from Goong API
        const response = await fetch(
          `https://rsapi.goong.io/Place/AutoComplete?api_key=YOUR_GOONG_API_KEY&input=${encodeURIComponent(query)}`
        );
        const data = await response.json();

        // Clear previous results
        autocompleteResults.innerHTML = "";

        // Display new results
        if (data.predictions && data.predictions.length > 0) {
          data.predictions.forEach((prediction) => {
            const resultItem = document.createElement("div");
            resultItem.className = "p-2 hover:bg-base-200 cursor-pointer";
            resultItem.textContent = prediction.description;
            resultItem.addEventListener("click", () => {
              this.handleAutocompleteSelect(prediction);
            });
            autocompleteResults.appendChild(resultItem);
          });
        } else {
          const noResults = document.createElement("div");
          noResults.className = "p-2 text-gray-500";
          noResults.textContent = "No results found";
          autocompleteResults.appendChild(noResults);
        }
      } else {
        autocompleteResults.innerHTML = "";
      }
    });
  }

  handleAutocompleteSelect(prediction) {
    // Set the selected location
    this.selectedLocation = {
      description: prediction.description,
      placeId: prediction.place_id,
    };

    // Update the search input with the selected location
    this.searchInputTarget.value = prediction.description;

    // Clear autocomplete results
    this.autocompleteResultsTarget.innerHTML = "";

    // Fetch details of the selected location (e.g., coordinates)
    this.fetchLocationDetails(prediction.place_id);
  }

  async fetchLocationDetails(placeId) {
    const response = await fetch(
      `https://rsapi.goong.io/Place/Detail?api_key=YOUR_GOONG_API_KEY&place_id=${placeId}`
    );
    const data = await response.json();

    if (data.result) {
      const { lat, lng } = data.result.geometry.location;
      this.selectedLocation.coordinates = { lat, lng };

      // Update the map to show the selected location
      this.updateMap(lng, lat);
    }
  }

  initializeMap() {
    // Initialize the Goong map
    this.goongMap = new window.Goong.Map({
      container: this.mapTarget,
      style: "https://tiles.goong.io/assets/goong_map_web.json",
      center: [105.83991, 21.028], // Default center (Hanoi, Vietnam)
      zoom: 12,
    });

    // Add a marker for the selected location
    this.marker = new window.Goong.Marker({
      draggable: true,
    });

    // Handle marker movement
    this.marker.on("dragend", () => {
      const { lng, lat } = this.marker.getLngLat();
      this.selectedLocation.coordinates = { lng, lat };
    });
  }

  updateMap(lng, lat) {
    // Update the map center and marker position
    this.goongMap.setCenter([lng, lat]);
    this.marker.setLngLat([lng, lat]).addTo(this.goongMap);
  }
}
