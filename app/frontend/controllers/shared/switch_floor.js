document.addEventListener('DOMContentLoaded', () => {
  const cards = document.querySelectorAll('.card');

  cards.forEach((card) => {
    const lowerFloor = card.querySelector('.lower-floor');
    const upperFloor = card.querySelector('.upper-floor');
    const lowerTab = card.querySelector('.lower-tab');
    const upperTab = card.querySelector('.upper-tab');

    if (lowerFloor && upperFloor && lowerTab && upperTab) {
      const showLower = () => {
        lowerFloor.classList.remove('hidden');
        upperFloor.classList.add('hidden');

        lowerTab.classList.add('border-b-2', 'border-blue-500', 'text-blue-500');
        upperTab.classList.remove('border-b-2', 'border-blue-500', 'text-blue-500');
      };

      const showUpper = () => {
        lowerFloor.classList.add('hidden');
        upperFloor.classList.remove('hidden');

        upperTab.classList.add('border-b-2', 'border-blue-500', 'text-blue-500');
        lowerTab.classList.remove('border-b-2', 'border-blue-500', 'text-blue-500');
      };

      lowerTab.addEventListener('click', showLower);
      upperTab.addEventListener('click', showUpper);

      showLower();
    }
  });
});
