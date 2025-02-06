# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  phone_number           :string           default(""), not null
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  uid                    :string
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  stripe_customer_id     :string
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_stripe_customer_id    (stripe_customer_id)
#
class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :validatable,
    :omniauthable,
    omniauth_providers: [:google_oauth2]

  # associations
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200]
  end
  has_many :bookings, dependent: :destroy, inverse_of: :user
  has_many :notifications, dependent: :destroy, inverse_of: :user

  # Scopes
  # Scopes
  scope :search,
    ->(query) {
      where('email ILIKE :search', search: "%#{query}%") if query.present?
    }

  scope :role_filter,
    ->(role) {
      with_role(role.downcase) if role.present? && %w[customer admin].include?(role.downcase)
    }

  scope :sort_by_param,
    ->(sort_param) {
      case sort_param&.downcase
      when 'oldest'
        order(created_at: :asc)
      when 'email_asc'
        order(email: :asc)
      when 'email_desc'
        order(email: :desc)
      else
        order(created_at: :desc)
      end
    }

  # validations
  validates :avatar,
    content_type: /\Aimage\/.*\z/,
    size: {
      less_than: 10.megabytes,
      message: I18n.t('activerecord.errors.models.user.attributes.avatar.size', size: 10)
    }
  validates :email,
    presence: true,
    uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, format: { with: /\A(03|05|07|08|09)\d{8}\z/ }, unless: -> { reset_password_token.present? }
  validates :password,
    if: -> { password.present? },
    confirmation: { message: I18n.t('activerecord.errors.models.user.attributes.password.confirmation') },
    format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+\z/, message: I18n.t('activerecord.errors.models.user.attributes.password.format') },
    length: { minimum: 8, message: I18n.t('activerecord.errors.models.user.attributes.password.too_short') }

  def self.from_google(google_params)
    create_with(
      uid: google_params[:uid],
      provider: 'google',
      password: Devise.friendly_token[0, 20]
    ).find_or_create_by!(email: google_params[:email])
  end

  def admin?
    has_role?(:admin)
  end

  def employee?
    !admin? && has_role?(:employee)
  end
end
