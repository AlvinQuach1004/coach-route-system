import { Controller } from '@hotwired/stimulus';
import { showToast } from './toast';
import mapboxgl from 'mapbox-gl';
import * as Sentry from '@sentry/browser';

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
    'pickupDateTime',
    'dropoffDateTime',
    'departureDateStep3',
    'departureTimeStep3',
    'departureDate',
    'departureTime',
    'dateBeforeDeparture',
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
    this.coachSpeed = 666.67;
    this.stops = JSON.parse(this.element.dataset.positionStops || '[]');
  }

  async updatePickup() {
    setTimeout(async () => {
      try {
        if (!this.hasPickupLocationTarget) return;

        const address = this.pickupLocationTarget.textContent.trim();
        console.log('Địa chỉ điểm đón:', address);

        if (address) {
          this.selectedPickup = await this.getCoordinatesFromAddress(address);
          await this.calculateTotalPrice();
          await this.updatePickupDepartureAndArrivalTime();
        }
      } catch (error) {
        // Capture the error with Sentry
        Sentry.captureException(error);
      }
    }, 500);
  }

  async updateDropoff() {
    setTimeout(async () => {
      try {
        if (!this.hasDropoffLocationTarget) return;

        const address = this.dropoffLocationTarget.textContent.trim();
        console.log('Địa chỉ điểm trả:', address);

        if (address) {
          this.selectedDropoff = await this.getCoordinatesFromAddress(address);
          await this.calculateTotalPrice();
          await this.updateDropoffDepartureAndArrivalTime();
        }
      } catch (error) {
        // Capture the error with Sentry
        Sentry.captureException(error);
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
      Sentry.captureException(error);
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
      Sentry.captureException(error);
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
        Sentry.captureException(error);
        return 0;
      });
  }

  calculateTicketPrice(distance) {
    try {
      if (!distance || isNaN(distance)) {
        showToast('Khoảng cách không hợp lệ!', 'warn');
        return 0;
      }

      const quantity = parseInt(this.totalQuantityTarget.textContent) || 1;
      const ticketPrice = Math.ceil(distance * this.pricePerKm * quantity);

      return ticketPrice;
    } catch (error) {
      // Capture the error with Sentry
      Sentry.captureException(error);
      return 0;
    }
  }

  async updateStep3Data(event) {
    try {
      event.preventDefault();

      setTimeout(async () => {
        if (this.stepIndex === 2) {
          console.log('Đang ở Step 2: Lấy khoảng cách & tính giá vé');
          console.log('Stops: ', this.stops);

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
            }
          }

          if (this.hasDropoffLocationTarget) {
            if (this.selectedDropoff) {
              const province = await this.getProvinceFromCoordinates(this.selectedDropoff);
              this.toStep3Target.textContent = province;
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
    } catch (error) {
      // Capture the error with Sentry
      Sentry.captureException(error);
    }
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
      Sentry.captureException(error);
      showToast(`Lỗi: ${error}`, 'alert');
      return 'Không xác định';
    }
  }

  formatCurrency(amount) {
    return amount.toLocaleString('vi-VN');
  }

  openPositionModal(event) {
    try {
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
    } catch (error) {
      // Log the error to Sentry
      Sentry.captureException(error);
      showToast('Something went wrong while opening the position modal. Please try again.', 'alert');
    }
  }

  closePositionModal(event) {
    try {
      event.preventDefault();
      const headerContainer = document.querySelector('.header-container');
      headerContainer.classList.add('sticky');
      this.positionModalTarget.classList.add('hidden');
    } catch (error) {
      Sentry.captureException(error);
    }
  }

  async showLocationOnMap(address) {
    try {
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
    } catch (error) {
      Sentry.captureException(error);
      showToast('Something went wrong while fetching the location. Please try again.', 'alert');
    }
  }

  initPositionMap() {
    try {
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
    } catch (error) {
      Sentry.captureException(error);
    }
  }

  updateStopIds() {
    try {
      this.updateStopId(this.fromStep3Target, this.startStopIdTarget, 'pickup');
      this.updateStopId(this.toStep3Target, this.endStopIdTarget, 'dropoff');
    } catch (error) {
      Sentry.captureException(error);
    }
  }

  updateStopId(locationElement, stopIdElement, stopType) {
    try {
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
    } catch (error) {
      Sentry.captureException(error);
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
      Sentry.captureException(error);
      showToast(`Lỗi ${error}`, 'alert');
      return 'Không xác định';
    }
  }

  calculateArrivalDate(departureTime, departureDate, timeRange) {
    try {
      // Chuyển departureDate từ dd/mm/yyyy -> yyyy-mm-dd để đảm bảo Date() hoạt động đúng
      let [day, month, year] = departureDate.split('/');
      let formattedDate = `${year}-${month}-${day}`; // yyyy-mm-dd

      // Tạo Date object từ departureDate và departureTime
      let departure = new Date(`${formattedDate}T${departureTime}:00`);

      if (isNaN(departure.getTime())) {
        throw new Error(`Invalid date: ${departureDate} ${departureTime}`);
      }

      departure.setMinutes(departure.getMinutes() + timeRange); // Cộng thêm thời gian di chuyển

      // Lấy ngày, tháng, năm từ đối tượng Date
      let newDay = departure.getDate().toString().padStart(2, '0');
      let newMonth = (departure.getMonth() + 1).toString().padStart(2, '0');
      let newYear = departure.getFullYear();

      let newDate = `${newDay}/${newMonth}/${newYear}`; // Format dd/mm/yyyy
      let newTime = departure.toTimeString().split(' ')[0].substring(0, 5); // Lấy HH:MM

      console.log('Updated Date:', newDate);
      console.log('Updated Time:', newTime);

      return { newTime, newDate };
    } catch (error) {
      Sentry.captureException(error);
      return { newTime: '00:00', newDate: '01/01/1970' }; // Trả về giá trị mặc định nếu có lỗi
    }
  }

  async updatePickupDepartureAndArrivalTime() {
    try {
      setTimeout(async () => {
        let minStop = this.stops.reduce((min, stop) => (stop.stop_order < min.stop_order ? stop : min), this.stops[0]);

        if (this.selectedPickup) {
          const coordsMinStopProvince = await this.getCoordinatesFromAddress(minStop.province);

          // Tính khoảng cách và thời gian từ minStop đến selectedPickup
          console.log('Min stop province: ', minStop.province);
          const distanceToPickup = await this.calculateDistance(coordsMinStopProvince, this.selectedPickup);
          console.log('Distance: ', distanceToPickup);
          const timeRangeToPickup = Math.ceil((distanceToPickup * 1000) / this.coachSpeed);
          console.log(timeRangeToPickup);
          const { newTime: pickupTime, newDate: pickupDate } = this.calculateArrivalDate(
            minStop.departure_time,
            minStop.departure_date,
            timeRangeToPickup,
          );
          console.log(this.dropoffLocationTarget);
          const coordsDropoffLocation = await this.getCoordinatesFromAddress(this.dropoffLocationTarget.textContent);
          const distanceDropoff = await this.calculateDistance(this.selectedPickup, coordsDropoffLocation);
          const timeRangeToDropoff = Math.ceil((distanceDropoff * 1000) / this.coachSpeed);
          const { newTime: dropoffTime, newDate: dropoffDate } = this.calculateArrivalDate(
            pickupTime,
            pickupDate,
            timeRangeToDropoff,
          );
          this.pickupDateTimeTarget.textContent = `${pickupTime} (${pickupDate})`;
          this.dropoffDateTimeTarget.textContent = `${dropoffTime} (${dropoffDate})`;
          this.departureDateStep3Target.textContent = pickupDate;
          this.departureTimeStep3Target.textContent = pickupTime;
          this.dateBeforeDepartureTarget.textContent = this.subtractOneDay(pickupDate);
        }
      }, 500);
    } catch (error) {
      Sentry.captureException(error);
    }
  }

  subtractOneDay(dateString) {
    let parts = dateString.split('/');
    let date = new Date(`${parts[2]}-${parts[1]}-${parts[0]}`);

    date.setDate(date.getDate() - 1);

    let day = date.getDate().toString().padStart(2, '0');
    let month = (date.getMonth() + 1).toString().padStart(2, '0');
    let year = date.getFullYear();

    return `${day}/${month}/${year}`;
  }

  async updateDropoffDepartureAndArrivalTime() {
    try {
      setTimeout(async () => {
        let minStop = this.stops.reduce((min, stop) => (stop.stop_order < min.stop_order ? stop : min), this.stops[0]);
        if (this.selectedDropoff) {
          const coordsMinStopProvince = await this.getCoordinatesFromAddress(minStop.province);

          // Tính khoảng cách và thời gian từ minStop đến selectedDropoff
          const distanceToDropoff = await this.calculateDistance(coordsMinStopProvince, this.selectedDropoff);
          const timeRangeToDropoff = Math.ceil((distanceToDropoff * 1000) / this.coachSpeed);
          const { newTime: dropoffTime, newDate: dropoffDate } = this.calculateArrivalDate(
            minStop.departure_time,
            minStop.departure_date,
            timeRangeToDropoff,
          );

          // Cập nhật thời gian trả khách
          this.dropoffDateTimeTarget.textContent = `${dropoffDate} (${dropoffTime})`;
        }
      }, 500);
    } catch (error) {
      Sentry.captureException(error);
    }
  }

  async updateHiddenFields() {
    try {
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
      this.departureDateTarget.value = this.departureDateStep3Target.textContent;
      this.departureTimeTarget.value = this.departureTimeStep3Target.textContent;

      console.log('Updated hidden fields: ', {
        ticketPrice: this.ticketPriceTarget?.value,
        pickupAddress: this.pickupAddressTarget?.value,
        dropoffAddress: this.dropoffAddressTarget?.value,
      });
    } catch (error) {
      Sentry.captureException(error);
    }
  }
}
