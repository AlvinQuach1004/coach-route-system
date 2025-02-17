routes = [
  ['Hà Nội', 'Phú Thọ', 'Yên Bái', 'Lào Cai'],
  ['TP. Hồ Chí Minh', 'Bến Tre', 'Trà Vinh', 'Sóc Trăng', 'Cần Thơ'],
  ['Tiền Giang', 'Vĩnh Long', 'Cần Thơ', 'Hậu Giang'],
  ['Long An', 'Tiền Giang', 'Bến Tre', 'Trà Vinh'],
  ['TP. Hồ Chí Minh', 'Bình Dương', 'Đồng Nai', 'Bà Rịa - Vũng Tàu'],
  ['TP. Hồ Chí Minh', 'Long An', 'Đồng Tháp', 'An Giang'],
  ['Bình Thuận', 'Ninh Thuận'],
  ['Bình Thuận', 'Khánh Hòa'],
  ['TP. Hồ Chí Minh', 'Bình Thuận', 'Ninh Thuận'],
  ['TP. Hồ Chí Minh', 'Kiên Giang'],
  ['Kiên Giang', 'Bạc Liêu'],
  ['Cần Thơ', 'Sóc Trăng', 'Bạc Liêu', 'Cà Mau'],
  ['Đà Nẵng', 'Quảng Nam', 'Quảng Ngãi', 'Bình Định', 'Khánh Hòa'],
  ['Hà Nội', 'Nghệ An', 'Thanh Hóa'],
  ['Hải Phòng', 'Hà Nội'],
  ['Hà Nội', 'Nam Định', 'Ninh Bình'],
  ['Đà Nẵng', 'Quảng Nam', 'Bình Định', 'Khánh Hòa', 'Hà Nội'],
  ['TP. Hồ Chí Minh', 'Hậu Giang', 'Cần Thơ', 'Sóc Trăng', 'Bạc Liêu', 'Cà Mau'],
  ['Thanh Hóa', 'Hà Tĩnh', 'Nghệ An']
]

special_stations = {
  'TP. Hồ Chí Minh' => 'Bến xe Miền Tây',
  'Hà Nội' => 'Bến xe Mỹ Đình'
}

routes.each do |locations|
  forward_route = Route.find_by(
    start_location_id: Location.find_by(name: locations.first).id,
    end_location_id: Location.find_by(name: locations.last).id
  )

  reverse_route = Route.find_by(
    start_location_id: Location.find_by(name: locations.last).id,
    end_location_id: Location.find_by(name: locations.first).id
  )

  [forward_route, reverse_route].each do |route|
    locations = route == forward_route ? locations : locations.reverse

    locations.each_with_index do |location, index|
      address = special_stations[location] || "Bến xe #{location}"

      stop_order = index + 1
      is_pickup = stop_order == 1 || (stop_order.even? && stop_order != locations.length)
      is_dropoff = stop_order == locations.length || (!is_pickup && stop_order.odd?)

      route.stops.create!(
        stop_order: stop_order,
        location_id: Location.find_by(name: location).id,
        is_pickup: is_pickup,
        is_dropoff: is_dropoff,
        time_range: (stop_order - 1) * 60,
        address: address,
        latitude_address: 0.0,
        longitude_address: 0.0
      )
    end
  end
end
