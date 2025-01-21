module Admin
  class DashboardController < ApplicationController
    layout 'admin'

    before_action :authenticate_user!

    def index; end
  end
end
