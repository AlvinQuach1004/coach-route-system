routes = Route.all

routes.each do |route|
  total_stops = rand(3..5) # Randomly decide the total number of stops for the route
  total_stops.times do |i|
    if i == 0
      # First stop: use the route's start location ID
      Stop.create!(
        route_id: route.id,
        stop_order: i + 1,
        time_range: rand(1..12),
        location_id: route.start_location_id
      )
    elsif i == total_stops - 1
      # Last stop: use the route's end location ID
      Stop.create!(
        route_id: route.id,
        stop_order: i + 1,
        time_range: rand(1..4),
        location_id: route.end_location_id
      )
    else
      location_id = (Location.pluck(:id) - [route.start_location_id, route.end_location_id]).sample
      Stop.create!(
        route_id: route.id,
        stop_order: i + 1,
        time_range: rand(1..4),
        location_id: location_id
      )
    end
  end
end
