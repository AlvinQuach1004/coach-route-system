FactoryBot.define do
  factory :notification do
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    is_read { false }
    user
    booking

    trait :read do
      is_read { true }
    end

    trait :unread do
      is_read { false }
    end
  end
end
