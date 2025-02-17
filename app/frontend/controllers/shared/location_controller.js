import { Controller } from '@hotwired/stimulus';
import mapboxgl from 'mapbox-gl';

export default class extends Controller {
  static targets = [
    'modal',
    'input',
    'mapContainer',
    'selectedLocation',
    'totalPriceStep2',
    'pickupPosition',
    'dropoffPosition',
  ];

  connect() {
    console.log('Connect to location controller');
    this.apiKey = import.meta.env.VITE_GOONG_API_KEY;
    this.mapboxToken = import.meta.env.VITE_MAPBOX_API_KEY;
    this.mapKey = import.meta.env.VITE_GOONG_MAP_KEY;
    this.maxResults = 5;
    this.selectedAddress = '';
    this.selectedLocationCoords = null;
    this.selectedProvince = null;
    this.selectedPickup = null;
    this.selectedDropoff = null;
    this.pricePerKm = 10000;
    this.initMap();
  }

  openModal() {
    const headerContainer = document.querySelector('.header-container');
    headerContainer.classList.remove('sticky');
    this.modalTarget.classList.remove('hidden');
  }

  closeModal(event) {
    event.preventDefault();
    const headerContainer = document.querySelector('.header-container');
    headerContainer.classList.add('sticky');
    this.modalTarget.classList.add('hidden');
    this.clearSuggestions();
  }

  async autocomplete() {
    try {
      const query = this.inputTarget.value.trim();
      if (query.length < 3) {
        this.clearSuggestions();
        return;
      }

      const url = `https://rsapi.goong.io/Place/AutoComplete?api_key=${this.apiKey}&input=${encodeURIComponent(query)}`;
      const response = await fetch(url);
      const data = await response.json();

      if (data.predictions) {
        this.renderSuggestions(data.predictions.slice(0, this.maxResults));
      }
    } catch (error) {
      console.log(error);
    }
  }

  renderSuggestions(suggestions) {
    this.clearSuggestions();

    const list = document.createElement('ul');
    list.classList.add(
      'absolute',
      'w-full',
      'bg-white',
      'border',
      'shadow-lg',
      'z-50',
      'max-h-56',
      'overflow-auto',
      'rounded-md',
    );

    suggestions.forEach((place) => {
      const item = document.createElement('li');
      item.classList.add('p-2', 'cursor-pointer', 'hover:bg-gray-200');
      item.textContent = place.description;
      item.onclick = (event) => {
        event.stopPropagation();
        event.preventDefault();
        this.selectSuggestion(place);
      };
      list.appendChild(item);
    });

    this.inputTarget.parentNode.appendChild(list);
  }

  clearSuggestions() {
    const existingList = this.inputTarget.parentNode.querySelector('ul');
    if (existingList) {
      existingList.remove();
    }
  }

  async selectSuggestion(place) {
    try {
      this.inputTarget.value = place.description;
      this.clearSuggestions();

      const url = `https://rsapi.goong.io/Place/Detail?api_key=${this.apiKey}&place_id=${place.place_id}`;
      const response = await fetch(url);

      if (!response.ok) {
        throw new Error(`Failed to fetch place details: ${response.statusText}`);
      }

      const data = await response.json();

      if (data.result) {
        const { formatted_address } = data.result;
        const { location } = data.result.geometry;

        this.selectedLocationCoords = [location.lng, location.lat];
        this.selectedAddress = formatted_address;
        this.selectedProvince = data.result.compound.province;
        this.addMarker();
      } else {
        throw new Error('No result found for this place');
      }
    } catch (error) {
      console.error('Error in selectSuggestion:', error);
    }
  }

  async confirmSelection(event) {
    event.preventDefault();
    event.stopPropagation();

    if (!this.selectedAddress) {
      return;
    }

    this.selectedLocationTarget.textContent = this.selectedAddress;
    this.closeModal(event);

    const stopsData = JSON.parse(this.selectedLocationTarget.dataset.locationStops);
    console.log('Stops data:', stopsData);

    const normalizeProvince = (province) => {
      return province
        ? province
            .replace(/^TP\.?\s*/, '')
            .trim()
            .toLowerCase()
        : '';
    };

    const matchedStops = stopsData.filter(
      (stop) => normalizeProvince(stop.province) === normalizeProvince(this.selectedProvince),
    );
    const nextButton = document.querySelector('#next');
    if (matchedStops.length > 0) {
      this.selectedLocationTarget.classList.remove('text-red-500');
      this.calculateDistance(matchedStops);
      nextButton.disabled = false;
    } else {
      this.selectedLocationTarget.textContent = 'Không tìm thấy điểm dừng trong cùng tỉnh!';
      this.selectedLocationTarget.classList.add('text-red-500');
      nextButton.disabled = true;
    }
  }

  async getCoordinatesFromAddress(address) {
    const url = `https://rsapi.goong.io/Geocode?api_key=${this.apiKey}&address=${encodeURIComponent(address)}`;

    try {
      const response = await fetch(url);
      const data = await response.json();

      if (data.results && data.results.length > 0) {
        return data.results[0].geometry.location;
      } else {
        console.error('Không tìm thấy tọa độ cho địa chỉ:', address);
        return null;
      }
    } catch (error) {
      console.error('Lỗi khi gọi API Goong:', error);
      return null;
    }
  }

  async calculateDistance(stops) {
    try {
      const origins = `${this.selectedLocationCoords[1]},${this.selectedLocationCoords[0]}`;
      const destinations = await this.getCoordinatesFromAddress(stops[0].address);
      const destinationsCoords = `${destinations.lat},${destinations.lng}`;
      const url = `https://rsapi.goong.io/DistanceMatrix?origins=${origins}&destinations=${destinationsCoords}&vehicle=hd&api_key=${this.apiKey}`;
      const response = await fetch(url);
      const data = await response.json();

      if (data.rows.length > 0 && data.rows[0].elements.length > 0) {
        const distances = data.rows[0].elements.map((element, index) => ({
          stop: stops[index],
          distance: element.distance.value,
        }));

        distances.sort((a, b) => a.distance - b.distance);

        if (distances.length > 0) {
          const nearestDistance = distances[0].distance / 1000;
          const nearestStop = distances[0].stop;
          const nextButton = document.querySelector('#next');
          if (nearestDistance > 30) {
            this.selectedLocationTarget.textContent = 'Điểm đón quá xa trạm !';
            this.selectedLocationTarget.classList.add('text-red-500');
            nextButton.disabled = true;
          } else {
            this.selectedLocationTarget.textContent = `${this.selectedAddress} (${nearestDistance.toFixed(2)} km)`;
            this.selectedLocationTarget.classList.remove('text-red-500');
            nextButton.disabled = false;
          }

          if (this.hasPickupPositionTarget) {
            console.log('Nearest stop:', nearestStop, `Distance: ${nearestDistance} km`);
            this.pickupPositionTarget.textContent = nearestStop.address;
          }

          if (this.hasDropoffPositionTarget) {
            console.log('Nearest stop:', nearestStop, `Distance: ${nearestDistance} km`);
            this.dropoffPositionTarget.textContent = nearestStop.address;
          }
        }
      }
    } catch (error) {
      console.error('Error fetching distance matrix:', error);
    }
  }

  formatCurrency(amount) {
    return amount.toLocaleString('vi-VN');
  }

  addMarker() {
    try {
      new mapboxgl.Marker().setLngLat(this.selectedLocationCoords).addTo(this.map);
      this.map.flyTo({ center: this.selectedLocationCoords, zoom: 14 });
    } catch (error) {}
  }

  initMap() {
    mapboxgl.accessToken = this.mapboxToken;
    this.map = new mapboxgl.Map({
      container: this.mapContainerTarget,
      style: `https://tiles.goong.io/assets/goong_map_web.json?api_key=${this.mapKey}`,
      center: [106.7009, 10.7754],
      zoom: 12,
    });
  }
}
