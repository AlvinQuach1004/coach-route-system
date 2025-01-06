FactoryBot.define do
  factory :booking do
    user
    payment_method { 'online' }
    payment_status { 'pending' }
    start_stop factory: %i[stop]
    end_stop factory: %i[stop]
  end
end
