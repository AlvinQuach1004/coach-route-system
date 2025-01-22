document.addEventListener('turbo:frame-load', function (event) {
  if (event.target.id === 'modal_routes') {
    initializeStopControls();
  }
});

document.addEventListener('DOMContentLoaded', function () {
  initializeStopControls();
});

function initializeStopControls() {
  const stopsContainer = document.querySelector('.stops-container');
  const addStopButton = document.querySelector('[data-add-stop]');
  const MAX_STOPS = 4;

  if (!stopsContainer || !addStopButton) return;

  // Add click handlers
  addStopButton.addEventListener('click', handleAddStop);
  stopsContainer.addEventListener('click', handleRemoveStop);

  // Handle adding a new stop
  function handleAddStop() {
    const stopCount = stopsContainer.querySelectorAll('.stop-field').length;

    if (stopCount >= MAX_STOPS) {
      addStopButton.classList.add('hidden');
      return;
    }

    const firstStop = stopsContainer.querySelector('.stop-field');
    if (!firstStop) return;

    const newStop = firstStop.cloneNode(true);

    // Clear form values
    newStop.querySelectorAll('input, select').forEach((input) => {
      const currentName = input.getAttribute('name');
      const currentId = input.getAttribute('id');

      // Clear value unless it's a stop_order field
      if (!currentName?.includes('[stop_order]')) {
        input.value = '';
      }

      // Update field indices
      if (currentName) {
        input.name = currentName.replace(/\[\d+\]/, `[${stopCount}]`);
      }
      if (currentId) {
        input.id = currentId.replace(/_\d+_/, `_${stopCount}_`);
      }
    });

    // Add remove button
    const removeButton = createRemoveButton();
    newStop.classList.add('relative');
    newStop.appendChild(removeButton);

    // Add to container and update UI
    stopsContainer.appendChild(newStop);
    updateStopOrders();
    updateAddButtonVisibility();
  }

  // Handle removing a stop
  function handleRemoveStop(event) {
    const removeButton = event.target.closest('[data-remove-stop]');
    if (!removeButton) return;

    const stopField = removeButton.closest('.stop-field');
    if (!stopField) return;

    const stopCount = stopsContainer.querySelectorAll('.stop-field').length;
    if (stopCount <= 1) return;

    stopField.remove();
    updateStopOrders();
    updateAddButtonVisibility();
  }

  function createRemoveButton() {
    const button = document.createElement('button');
    button.type = 'button';
    button.setAttribute('data-remove-stop', '');
    button.className = 'btn btn-ghost btn-circle btn-sm absolute right-2 top-2';
    button.innerHTML = `
    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
      </svg>`;
    return button;
  }

  function updateStopOrders() {
    const actionLabel = document.querySelector('.action-label');
    const isNewRoute = actionLabel.innerText === 'New Route';

    stopsContainer.querySelectorAll('.stop-field').forEach((stop, index) => {
      const orderInput = stop.querySelector('input[name*="[stop_order]"]');

      if (orderInput.value && isNewRoute) {
        orderInput.value = index + 2;
      }
    });
  }

  function updateAddButtonVisibility() {
    const stopCount = stopsContainer.querySelectorAll('.stop-field').length;
    addStopButton.classList.toggle('hidden', stopCount >= MAX_STOPS);
  }

  updateStopOrders();
  updateAddButtonVisibility();
}
