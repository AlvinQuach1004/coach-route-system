document.addEventListener('DOMContentLoaded', () => {
  // Chọn tất cả các card có dropdown
  const cards = document.querySelectorAll('.card');

  // Lặp qua từng card
  cards.forEach((card) => {
    const lowerFloor = card.querySelector('.lower-floor');
    const upperFloor = card.querySelector('.upper-floor');
    const lowerTab = card.querySelector('.lower-tab');
    const upperTab = card.querySelector('.upper-tab');

    // Đảm bảo các biến không null trước khi gán sự kiện
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

      // Gán sự kiện cho từng tab của card hiện tại
      lowerTab.addEventListener('click', showLower);
      upperTab.addEventListener('click', showUpper);

      // Mặc định hiển thị lower floor khi load trang
      showLower();
    }
  });
});
