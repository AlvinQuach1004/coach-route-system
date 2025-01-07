routes = Route.all
coaches = Coach.all


50.times do
  route = routes.sample
  coach = coaches.sample

  departure_date = Faker::Date.between(from: Date.today, to: 1.month.from_now)
  departure_time = Faker::Time.between(from: "08:00", to: "22:00", format: :short)

  Schedule.create!(
    route_id: route.id,
    coach_id: coach.id,
    departure_date: departure_date,
    departure_time: departure_time
  )
end
