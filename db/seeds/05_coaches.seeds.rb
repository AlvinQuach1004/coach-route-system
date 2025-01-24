coach_types = ["sleeper", "room", "limousine"]
license_plate_prefix = %w[51 52 53 54 55 56 57 58 59]

20.times do
  Coach.create!(
    license_plate: "#{license_plate_prefix.sample}B-#{rand(10000..99999)}",
    coach_type: coach_types.sample,
    status: 'available',
    capacity: rand(30..50)
  )
end
