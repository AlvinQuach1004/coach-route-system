# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  devise_for :users, only: :omniauth_callbacks, controllers: { omniauth_callbacks: 'authentication/omniauth_callbacks' }
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do # rubocop:disable Metrics/BlockLength
    mount ActionCable.server => '/cable'
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
      skip: :omniauth_callbacks,
      controllers: {
        sessions: 'authentication/sessions',
        registrations: 'authentication/registrations',
        passwords: 'authentication/passwords'
      }

    resource :profile, only: [:show] do
      patch :update_field, on: :member
    end

    resources :notifications, only: [:index] do
      member do
        post :mark_as_read
      end
      collection do
        post :mark_all_as_read
      end
    end

    get '/locations/search', to: 'locations#search'

    namespace :admin do
      resources :users
      resources :coach_routes
      resources :schedules
      resources :bookings
      root 'dashboard#index'
      get 'dashboard', to: 'dashboard#index'
    end

    namespace :customers do
      # Add employee routes here
    end

    root 'home#index'
    get 'up' => 'rails/health#show', as: :rails_health_check
  end
end
