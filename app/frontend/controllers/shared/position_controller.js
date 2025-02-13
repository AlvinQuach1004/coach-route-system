import { Controller } from '@hotwired/stimulus';
import { showToast } from './toast';
import mapboxgl from 'mapbox-gl';

export default class extends Controller {
  static targets = [
    'positionModal',
    'positionMapContainer',
    'pickupLocation',
    'dropoffLocation',
    'totalPriceStep2',
    'totalQuantity',
    'priceStep3',
    'totalQuantityStep3',
    'fromStep3',
    'toStep3',
    'totalPriceStep3',
    'startStopId',
    'endStopId',
    'ticketPrice',
    'pickupAddress',
    'dropoffAddress',
    'next',
  ];

  connect() {
    this.apiKey = import.meta.env.VITE_GOONG_API_KEY;
    this.mapboxToken = import.meta.env.VITE_MAPBOX_API_KEY;
    this.mapKey = import.meta.env.VITE_GOONG_MAP_KEY;
    this.selectedPickup = null;
    this.selectedDropoff = null;
    this.stepIndex = 1;
    this.pricePerKm = 1000;
    this.stops = JSON.parse(this.element.dataset.positionStops || '[]');
  }

  async updatePickup() {
    setTimeout(async () => {
      if (!this.hasPickupLocationTarget) return;

      const address = this.pickupLocationTarget.textContent.trim();
      console.log('Địa chỉ điểm đón:', address);

      if (address) {
        this.selectedPickup = await this.getCoordinatesFromAddress(address);
        await this.calculateTotalPrice();
      }
    }, 500);
  }

  async updateDropoff() {
    setTimeout(async () => {
      if (!this.hasDropoffLocationTarget) return;

      const address = this.dropoffLocationTarget.textContent.trim();
      console.log('Địa chỉ điểm trả:', address);

      if (address) {
        this.selectedDropoff = await this.getCoordinatesFromAddress(address);
        await this.calculateTotalPrice();
      }
    }, 500);
  }

  async getCoordinatesFromAddress(address) {
    const url = `https://rsapi.goong.io/Geocode?api_key=${this.apiKey}&address=${encodeURIComponent(address)}`;

    try {
      const response = await fetch(url);
      const data = await response.json();

      if (data.results && data.results.length > 0) {
        return data.results[0].geometry.location;
      }
      showToast('Không tìm thấy tọa độ cho địa chỉ', 'warn');
      return null;
    } catch (error) {
      showToast(`Lỗi ${error}`, 'alert');
      return null;
    }
  }

  async calculateTotalPrice() {
    // Nếu chưa có selectedPickup hoặc selectedDropoff, lấy giá trị từ DOM
    if (!this.selectedPickup && this.hasPickupLocationTarget) {
      this.selectedPickup = await this.getCoordinatesFromAddress(this.pickupLocationTarget.textContent.trim());
    }

    if (!this.selectedDropoff && this.hasDropoffLocationTarget) {
      this.selectedDropoff = await this.getCoordinatesFromAddress(this.dropoffLocationTarget.textContent.trim());
    }

    if (!this.selectedPickup || !this.selectedDropoff) {
      showToast('Chưa có đủ điểm đón và điểm trả!', 'warn');
      return;
    }

    const origins = `${this.selectedPickup.lat},${this.selectedPickup.lng}`;
    const destinations = `${this.selectedDropoff.lat},${this.selectedDropoff.lng}`;
    const url = `https://rsapi.goong.io/DistanceMatrix?origins=${origins}&destinations=${destinations}&vehicle=car&api_key=${this.apiKey}`;

    try {
      const response = await fetch(url);
      const data = await response.json();

      if (data.rows.length > 0 && data.rows[0].elements.length > 0) {
        const distance = data.rows[0].elements[0].distance.value / 1000;
        const totalPrice = Math.ceil(distance * this.pricePerKm * parseInt(this.totalQuantityTarget.textContent));

        console.log(`📏 Khoảng cách: ${distance.toFixed(2)} km`);
        console.log(`💰 Tổng giá: ${totalPrice.toLocaleString()} VND`);

        if (this.hasTotalPriceStep2Target) {
          this.totalPriceStep2Target.textContent = `${this.formatCurrency(totalPrice)}₫`;
        } else {
          showToast('Không tìm thấy phần tử hiển thị giá!', 'warn');
        }
      }
    } catch (error) {
      showToast(`Lỗi: ${error} khi tính khoảng cách`, 'alert');
    }
  }

  backStep() {
    this.stepIndex--;
  }

  nextStep() {
    this.stepIndex++;
  }

  async calculateDistance(pickupLocation, dropoffLocation) {
    const origins = `${pickupLocation.lat},${pickupLocation.lng}`;
    const destinations = `${dropoffLocation.lat},${dropoffLocation.lng}`;
    const url = `https://rsapi.goong.io/DistanceMatrix?origins=${origins}&destinations=${destinations}&vehicle=hd&api_key=${this.apiKey}`;

    return fetch(url)
      .then((response) => response.json())
      .then((data) => {
        if (data.rows.length > 0 && data.rows[0].elements.length > 0) {
          const distance = data.rows[0].elements[0].distance.value / 1000; // Convert meters to km
          return distance;
        }
        showToast('Không lấy được khoảng cách!', 'warn');
        return 0;
      })
      .catch((error) => {
        showToast(`Lỗi: ${error} khi tính khoảng cách`, 'alert');
        return 0;
      });
  }

  calculateTicketPrice(distance) {
    if (!distance || isNaN(distance)) {
      showToast('Khoảng cách không hợp lệ!', 'warn');
      return 0;
    }

    const quantity = parseInt(this.totalQuantityTarget.textContent) || 1;
    const ticketPrice = Math.ceil(distance * this.pricePerKm * quantity);

    return ticketPrice;
  }

  async updateStep3Data(event) {
    event.preventDefault();

    setTimeout(async () => {
      if (this.stepIndex === 2) {
        console.log('Đang ở Step 2: Lấy khoảng cách & tính giá vé');

        if (this.hasPickupLocationTarget && this.hasDropoffLocationTarget) {
          console.log('Lấy vị trí đón và trả');

          const pickupLocation = await this.getCoordinatesFromAddress(this.pickupLocationTarget.textContent);
          const dropoffLocation = await this.getCoordinatesFromAddress(this.dropoffLocationTarget.textContent);

          if (pickupLocation && dropoffLocation) {
            const distance = await this.calculateDistance(pickupLocation, dropoffLocation);

            const ticketPrice = this.calculateTicketPrice(distance);

            if (this.hasTotalPriceStep2Target) {
              this.totalPriceStep2Target.textContent = `${this.formatCurrency(ticketPrice)}₫`;
            }
          }
        }
      }

      if (this.stepIndex === 3) {
        if (this.hasPriceStep3Target && this.hasTotalPriceStep2Target && this.hasTotalQuantityTarget) {
          const totalPrice = parseFloat(this.totalPriceStep2Target.textContent.replace(/[^\d]/g, '')) || 0;
          const totalQuantity = parseInt(this.totalQuantityTarget.textContent, 10) || 1;
          const pricePerTicket = totalPrice / totalQuantity;

          this.priceStep3Target.textContent = `${this.formatCurrency(pricePerTicket)}₫`;
        }

        let quantity = this.hasTotalQuantityTarget ? parseInt(this.totalQuantityTarget.textContent, 10) : 1;
        if (this.hasTotalQuantityStep3Target) {
          this.totalQuantityStep3Target.textContent = quantity;
        }

        if (this.hasPickupLocationTarget) {
          if (this.selectedPickup) {
            const province = await this.getProvinceFromCoordinates(this.selectedPickup);
            this.fromStep3Target.textContent = province;
          } else {
            const pickupLocationCoords = await this.getCoordinatesFromAddress(this.pickupLocationTarget.textContent);
            const pickupLocationProvince = await this.getProvinceFromCoordinates(pickupLocationCoords);
            this.fromStep3Target.textContent = pickupLocationProvince;
          }
        }

        console.log('To: ', this.toStep3Target);
        if (this.hasDropoffLocationTarget) {
          if (this.selectedDropoff) {
            const province = await this.getProvinceFromCoordinates(this.selectedDropoff);
            this.toStep3Target.textContent = province;
          } else {
            const dropoffLocationCoords = await this.getCoordinatesFromAddress(this.dropoffLocationTarget.textContent);
            const dropoffLocationProvince = await this.getProvinceFromCoordinates(dropoffLocationCoords);
            this.toStep3Target.textContent = dropoffLocationProvince;
          }
        }

        console.log('Total: ', this.totalPriceStep3Target);
        if (this.hasTotalPriceStep3Target && this.hasTotalPriceStep2Target) {
          let pricePerTicket = parseFloat(this.priceStep3Target.textContent.replace(/[^\d]/g, '')) || 0;
          let totalPrice = pricePerTicket * quantity;
          this.totalPriceStep3Target.textContent = `${this.formatCurrency(totalPrice)}₫`;
        }
        this.updateStopIds();
        await this.updateHiddenFields();
      } else {
        console.log('Chưa đến Step 3');
      }
    }, 500);
  }

  async getProvinceFromCoordinates(coords) {
    const url = `https://rsapi.goong.io/Geocode?latlng=${coords.lat},${coords.lng}&api_key=${this.apiKey}`;
    try {
      const response = await fetch(url);
      const data = await response.json();

      if (data.results && data.results.length > 0) {
        const province = data.results[0].compound.province;
        return province;
      }
      return 'Không xác định';
    } catch (error) {
      showToast(`Lỗi: ${error}`, 'alert');
      return 'Không xác định';
    }
  }

  formatCurrency(amount) {
    return amount.toLocaleString('vi-VN');
  }

  openPositionModal(event) {
    event.preventDefault();
    this.positionModalTarget.classList.remove('hidden');
    const headerContainer = document.querySelector('.header-container');
    headerContainer.classList.remove('sticky');

    // Get the address from the clicked route's context
    const addressElement = event.target.closest('div').querySelector('[data-position-target]');
    if (addressElement) {
      const address = addressElement.textContent.trim();
      this.showLocationOnMap(address);
    }
  }

  closePositionModal(event) {
    event.preventDefault();
    const headerContainer = document.querySelector('.header-container');
    headerContainer.classList.add('sticky');
    this.positionModalTarget.classList.add('hidden');
  }

  async showLocationOnMap(address) {
    const url = `https://rsapi.goong.io/Geocode?address=${encodeURIComponent(address)}&api_key=${this.apiKey}`;
    const response = await fetch(url);
    const data = await response.json();
    if (data.results.length > 0) {
      const { lat, lng } = data.results[0].geometry.location;
      this.selectedLocation = [lng, lat];
      this.initPositionMap();
    } else {
      showToast('Không tìm thấy vị trí!', 'alert');
    }
  }

  initPositionMap() {
    if (this.positionMap) {
      this.positionMap.remove();
    }

    this.positionMap = new mapboxgl.Map({
      container: this.positionMapContainerTarget,
      style: `https://tiles.goong.io/assets/goong_map_web.json?api_key=${this.mapKey}`,
      center: this.selectedLocation,
      zoom: 14,
    });

    new mapboxgl.Marker().setLngLat(this.selectedLocation).addTo(this.positionMap);
  }

  updateStopIds() {
    this.updateStopId(this.fromStep3Target, this.startStopIdTarget, 'pickup');
    this.updateStopId(this.toStep3Target, this.endStopIdTarget, 'dropoff');
  }

  updateStopId(locationElement, stopIdElement, stopType) {
    const locationName = locationElement.textContent.trim();
    if (!locationName) return;

    const isPickup = stopType === 'pickup';
    const normalizeText = (text) => text.normalize('NFC').toLowerCase().replace(/\s+/g, ' ').trim();

    const stop = this.stops.find((s) => {
      const normalizedProvince = normalizeText(s.province);
      const normalizedLocation = normalizeText(locationName);

      return s[isPickup ? 'pickup' : 'dropoff'] && normalizedProvince.includes(normalizedLocation);
    });

    if (stop) {
      stopIdElement.value = stop.id;
    } else {
      stopIdElement.value = stopIdElement.dataset.defaultValue || '';
    }
  }

  async getAddressFromCoordinates(coords) {
    const url = `https://rsapi.goong.io/Geocode?latlng=${coords.lat},${coords.lng}&api_key=${this.apiKey}`;

    try {
      const response = await fetch(url);
      const data = await response.json();
      if (data.results && data.results.length > 0) {
        const address = data.results[0].name;
        return address;
      }
      return 'Không xác định';
    } catch (error) {
      showToast(`Lỗi ${error}`, 'alert');
      return 'Không xác định';
    }
  }

  async updateHiddenFields() {
    if (this.hasTicketPriceTarget && this.hasPriceStep3Target) {
      this.ticketPriceTarget.value = this.priceStep3Target.textContent.replace(/[^\d]/g, '') || '0';
    }

    if (this.hasPickupAddressTarget && this.selectedPickup) {
      const pickupAddress = await this.getAddressFromCoordinates(this.selectedPickup);
      this.pickupAddressTarget.value = pickupAddress;
    }

    if (this.hasDropoffAddressTarget && this.selectedDropoff) {
      const dropoffAddress = await this.getAddressFromCoordinates(this.selectedDropoff);
      this.dropoffAddressTarget.value = dropoffAddress;
    }

    console.log('Updated hidden fields: ', {
      ticketPrice: this.ticketPriceTarget?.value,
      pickupAddress: this.pickupAddressTarget?.value,
      dropoffAddress: this.dropoffAddressTarget?.value,
    });
  }
}
