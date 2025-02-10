coach_types = ["sleeper", "room", "limousine"]
license_plate_prefix = %w[51 52 53 54 55 56 57 58 59]
capacity_mapping = { "sleeper" => 36, "room" => 32, "limousine" => 28 }

20.times do
  coach_type = coach_types.sample
  Coach.create!(
    license_plate: "#{license_plate_prefix.sample}B-#{rand(10000..99999)}",
    coach_type: coach_type,
    status: Coach::Status::AVAILABLE,
    capacity: capacity_mapping[coach_type]
  )
end
