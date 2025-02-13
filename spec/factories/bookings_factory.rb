FactoryBot.define do
  factory :booking do
    user
    payment_method { ['online'].sample }
    payment_status { ['pending', 'completed', 'failed'].sample }
    start_stop factory: %i[stop]
    end_stop factory: %i[stop]
  end
end
