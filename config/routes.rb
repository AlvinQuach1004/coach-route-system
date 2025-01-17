# frozen_string_literal: true

Rails.application.routes.draw do
  resources :route_pages, only: [:index]

  resources :bookings do
    member do
      get :invoice
    end
    collection do
      get :error_payment
      get :thank_you
    end
  end

  resources :history, only: [:index]

  resources :payments, only: [:create] do
    member do
      get :cancel
    end
  end

  if Rails.env.development?
    get '/erd', to: 'docs#erd'
  end

  authenticate :user, lambda { |u| u.has_role?(:super_admin) } do
    mount Sidekiq::Web => '/sidekiq'
    unless Rails.env.production?
      get 'admin/console', to: 'admin/console#index'
    end
  end

  devise_for :users,
    controllers: {
      sessions: 'authentication/sessions',
      registrations: 'authentication/registrations',
      omniauth_callbacks: 'authentication/omniauth_callbacks',
      passwords: 'authentication/passwords'
    }

  namespace :admin do
    resources :users

    root to: 'users#index'
  end

  namespace :customers do
    # Add employee routes here
  end

  root 'home#index'
  get 'up' => 'rails/health#show', as: :rails_health_check
end
