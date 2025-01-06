locations = Location.all

20.times do
  start_location = locations.sample
  end_location = locations.reject { |location| location == start_location }.sample

  Route.create!(
    start_location: start_location,
    end_location: end_location
  )
end
