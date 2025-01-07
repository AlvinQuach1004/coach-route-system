routes = Route.all

routes.each do |route|
  rand(3..5).times do |i|
    Stop.create!(
      route_id: route.id,
      stop_order: i + 1,
      time_range: rand(1..4),
      location_id: route.start_location_id
    )
  end
end
