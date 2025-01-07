# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend
  def format_currency_vnd(amount)
    number_to_currency(amount, unit: 'đ', delimiter: ',', precision: 0, format: '%n%u')
  end
end
