import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['content', 'tab', 'tabPanel', 'progressBar', 'stepTab', 'bookContainer'];

  connect() {
    if (this.hasTabTarget && this.hasTabPanelTarget) {
      if (!this.tabTargets.find((tab) => tab.classList.contains('tab-active'))) {
        this.activateTab(this.tabTargets[0]);
      }
    }
  }

  toggle(event) {
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

        // Show current dropdown
        this.openDropdown(targetDropdown, cardContainer);
      } else {
        // Hide current dropdown
        this.closeDropdown(targetDropdown, cardContainer);
      }
    }
  }

  openDropdown(dropdown, container) {
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
  }

  closeDropdown(dropdown, container) {
    dropdown.classList.add('hidden');
    container.style.marginBottom = '20px';
    container.classList.remove('dropdown-open');
    this.isOpenValue = false;
  }

  showDetailTab(event) {
    event.preventDefault();
    this.activateTab(event.currentTarget);
  }

  activateTab(selectedTab) {
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

    // Update tab states within this dropdown only
    const tabsInDropdown = dropdownContainer.querySelectorAll('[data-dropdown-target="tab"]');
    tabsInDropdown.forEach((tab) => {
      tab.classList.remove('tab-active');
    });
    selectedTab.classList.add('tab-active');
  }
}
