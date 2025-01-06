FactoryBot.define do
  factory :route do
    transient do
      same_location { false }
    end

    start_location factory: %i[location]
    end_location factory: %i[location]

    after(:build) do |route, evaluator|
      if evaluator.same_location
        route.end_location = route.start_location
      else
        route.end_location ||= FactoryBot.create(:location)
      end
    end
  end
end
