class BookingPolicy < ApplicationPolicy
  attr_reader :user, :booking

  def initialize(user, booking) # rubocop:disable Lint/MissingSuper
    @user = user
    @booking = booking
  end

  def create?
    user.present? && booking.user_id == user.id
  end
end
