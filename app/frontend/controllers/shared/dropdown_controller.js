import { Controller } from '@hotwired/stimulus';
import * as Sentry from '@sentry/browser';

export default class extends Controller {
  static targets = ['content', 'tab', 'tabPanel', 'progressBar', 'stepTab', 'bookContainer'];

  connect() {
    try {
      if (this.hasTabTarget && this.hasTabPanelTarget) {
        if (!this.tabTargets.find((tab) => tab.classList.contains('tab-active'))) {
          this.activateTab(this.tabTargets[0]);
        }
      }
    } catch (error) {
      Sentry.captureException(error); // Log the error to Sentry
      console.error('Error during connect:', error);
    }
  }

  toggle(event) {
    try {
      event.preventDefault();
      event.stopPropagation();

      const dropdownId = event.params.id;
      const button = event.currentTarget;
      const cardContainer = button.closest('.card-container');

      // Get all dropdowns in the current card
      const allDropdowns = cardContainer.querySelectorAll('.dropdown-content-card');
      const targetDropdown = document.getElementById(dropdownId);

      // Close any other open dropdowns in the same card
      allDropdowns.forEach((dropdown) => {
        if (dropdown.id !== dropdownId && !dropdown.classList.contains('hidden')) {
          this.closeDropdown(dropdown, cardContainer);
        }
      });

      if (targetDropdown) {
        const isHidden = targetDropdown.classList.contains('hidden');

        if (isHidden) {
          // Close dropdowns in other cards
          document.querySelectorAll('.card-container').forEach((container) => {
            if (container !== cardContainer) {
              container.querySelectorAll('.dropdown-content-card').forEach((dropdown) => {
                this.closeDropdown(dropdown, container);
              });
            }
          });

          this.openDropdown(targetDropdown, cardContainer);
        } else {
          this.closeDropdown(targetDropdown, cardContainer);
        }
      }
    } catch (error) {
      Sentry.captureException(error); // Log the error to Sentry
      console.error('Error during toggle:', error);
    }
  }

  openDropdown(dropdown, container) {
    try {
      dropdown.classList.remove('hidden');
      const dropdownHeight = dropdown.offsetHeight;
      container.style.marginBottom = `${dropdownHeight + 40}px`;
      container.classList.add('dropdown-open');
      this.isOpenValue = true;

      // Set default tab for detail dropdown
      if (!dropdown.id.includes('book')) {
        const pickupTabId = dropdown.querySelector('[id^="pickup-"]')?.id;
        if (pickupTabId) {
          const pickupTab = dropdown.querySelector(`[data-dropdown-id-param="${pickupTabId}"]`);
          if (pickupTab) {
            this.activateTab(pickupTab);
          }
        }
      }
    } catch (error) {
      Sentry.captureException(error); // Log the error to Sentry
      console.error('Error during openDropdown:', error);
    }
  }

  closeDropdown(dropdown, container) {
    try {
      dropdown.classList.add('hidden');
      container.style.marginBottom = '20px';
      container.classList.remove('dropdown-open');
      this.isOpenValue = false;
    } catch (error) {
      Sentry.captureException(error); // Log the error to Sentry
      console.error('Error during closeDropdown:', error);
    }
  }

  showDetailTab(event) {
    try {
      event.preventDefault();
      this.activateTab(event.currentTarget);
    } catch (error) {
      Sentry.captureException(error); // Log the error to Sentry
      console.error('Error during showDetailTab:', error);
    }
  }

  activateTab(selectedTab) {
    try {
      if (!selectedTab) return;

      const tabId = selectedTab.dataset.dropdownIdParam;
      if (!tabId) {
        console.error('No tab ID found');
        return;
      }

      // Find the current dropdown container
      const dropdownContainer = selectedTab.closest('[data-controller="dropdown"]');
      if (!dropdownContainer) return;

      // Hide all panels within this dropdown only
      const allPanelsInDropdown = dropdownContainer.querySelectorAll('[data-dropdown-target="tabPanel"]');
      allPanelsInDropdown.forEach((panel) => {
        panel.classList.add('hidden');
      });
      // Show selected panel
      const selectedPanel = dropdownContainer.querySelector(`#${tabId}`);
      if (selectedPanel) {
        selectedPanel.classList.remove('hidden');
      }

      const tabsInDropdown = dropdownContainer.querySelectorAll('[data-dropdown-target="tab"]');
      tabsInDropdown.forEach((tab) => {
        tab.classList.remove('tab-active');
      });
      selectedTab.classList.add('tab-active');
    } catch (error) {
      Sentry.captureException(error); // Log the error to Sentry
      console.error('Error during activateTab:', error);
    }
  }
}
