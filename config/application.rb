# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
require 'groupdate'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsBoilerplate
  class Application < Rails::Application
    # Prevents Rails from trying to eager-load the contents of app/frontend
    config.javascript_path = 'frontend'
    config.action_controller.forgery_protection_origin_check = false

    config.i18n.available_locales = [:en, :vi]
    config.i18n.default_locale = :en

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks generators templates devise])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = 'Asia/Ho_Chi_Minh'
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    routes.default_url_options = {
      host: ENV.fetch('APP_HOST', 'localhost:3000'),
      protocol: ENV.fetch('APP_PROTOCOL', 'http')
    }

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.autoload_paths += Rails.root.glob('app/notifiers/**/*.rb')

    config.i18n.default_locale = :en
    config.i18n.load_path += Rails.root.glob('config/locales/**/*.{rb, yml}')
    config.i18n.fallbacks = [I18n.default_locale]

    # Enable web console in browser - protected by devise
    config.web_console.development_only = false
    config.web_console.permissions = '0.0.0.0/0'
  end
end
