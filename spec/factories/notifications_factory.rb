# spec/factories/notifications.rb
FactoryBot.define do
  factory :notification do
    recipient factory: %i[user]
    type { ['DepartureCableNotifier::Notification', 'PaymentReminderCableNotifier::Notification'].sample }
    params { { key: 'value' } }
    read_at { nil }

    trait :read do
      read_at { Time.current }
    end

    trait :departure do
      type { 'DepartureCableNotifier::Notification' }
    end

    trait :payment_reminder do
      type { 'PaymentReminderCableNotifier::Notification' }
    end
  end
end
