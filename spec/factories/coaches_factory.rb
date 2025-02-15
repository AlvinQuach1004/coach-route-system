FactoryBot.define do
  factory :coach do
    license_plate { Faker::Vehicle.license_plate }
    coach_type { %w[sleeper limousine room].sample }

    capacity do
      case coach_type
      when 'limousine' then Coach::Capacity::LIMOUSINE
      when 'room' then Coach::Capacity::ROOM
      when 'sleeper' then Coach::Capacity::SLEEPER
      end
    end

    status { Coach::Status::AVAILABLE }
  end
end
