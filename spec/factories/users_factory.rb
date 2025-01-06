FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@rails.boilerplate.com" }
    password { 'Password123!' }
    phone_number { '0912345678' }
    confirmed_at { Time.current }
    after(:build) { |user| user.add_role(:customer) }

    trait :admin do
      sequence(:email) { |n| "admin#{n}@rails.boilerplate.com" }
      after(:create) do |user|
        user.remove_role(:customer)
        user.add_role(:admin)
      end
    end
  end
end
