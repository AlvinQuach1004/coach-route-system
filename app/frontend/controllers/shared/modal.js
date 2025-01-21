document.addEventListener('DOMContentLoaded', () => {
  const modals = document.querySelectorAll('dialog.modal');

  modals.forEach((modal) => {
    const closeButtons = modal.querySelectorAll('.modal-close-button');
    const openButtons = document.querySelectorAll('.modal-open-button');

    // Show modal (display modal dialog)
    openButtons.forEach((button) => {
      button.addEventListener('click', (event) => {
        event.preventDefault();

        modals.forEach((m) => {
          if (m.open) m.close();
        });

        modal.showModal();
      });
    });

    // Close modal when clicking on cancel buttons or the close button
    closeButtons.forEach((button) => {
      button.addEventListener('click', (event) => {
        event.preventDefault();
        modal.close();
      });
    });

    // Close modal when clicking outside of modal-box
    modal.addEventListener('click', (event) => {
      const modalBox = modal.querySelector('.modal-box');
      if (event.target === modal && !modalBox.contains(event.target)) {
        modal.close();
      }
    });
  });
});
