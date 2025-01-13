# Ví dụ về cách tạo stops cho các tuyến đường đã liệt kê

# Tạo stops cho tuyến TP.HCM -> Bạc Liêu -> Sóc Trăng -> Cần Thơ -> Sài Gòn
route_1 = Route.find_by(start_location_id: Location.find_by(name: 'Cà Mau').id, end_location_id: Location.find_by(name: 'TP. Hồ Chí Minh').id)

route_1.stops.create!(
  stop_order: 1,
  location_id: Location.find_by(name: 'Cà Mau').id,
  is_pickup: true,
  address: 'Bến xe Cà Mau',
  latitude_address: 9.175,
  longitude_address: 105.145,
  time_range: 0
)

route_1.stops.create!(
  stop_order: 2,
  location_id: Location.find_by(name: 'Bạc Liêu').id,
  is_pickup: false,
  address: 'Bến xe Bạc Liêu',
  latitude_address: 9.287,
  longitude_address: 105.349,
  time_range: 60
)

route_1.stops.create!(
  stop_order: 3,
  location_id: Location.find_by(name: 'Sóc Trăng').id,
  is_pickup: false,
  address: 'Bến xe Sóc Trăng',
  latitude_address: 9.596,
  longitude_address: 105.965,
  time_range: 80
)

route_1.stops.create!(
  stop_order: 4,
  location_id: Location.find_by(name: 'Cần Thơ').id,
  is_pickup: true,
  is_dropoff: true,
  address: 'Bến xe Cần Thơ',
  latitude_address: 10.045,
  longitude_address: 105.746,
  time_range: 125
)

route_1.stops.create!(
  stop_order: 5,
  location_id: Location.find_by(name: 'Hậu Giang').id,
  is_pickup: false,
  address: 'Bến xe Hậu Giang',
  latitude_address: 9.781,
  longitude_address: 105.477,
  time_range: 200
)

route_1.stops.create!(
  stop_order: 6,
  location_id: Location.find_by(name: 'TP. Hồ Chí Minh').id,
  is_dropoff: true,
  address: 'Bến xe Miền Tây',
  latitude_address: 10.755,
  longitude_address: 106.659,
  time_range: 360
)


# Tạo stops cho tuyến TP.HCM -> Cần Thơ -> Sóc Trăng -> Bạc Liêu -> Cà Mau
route_2 = Route.find_by(start_location_id: Location.find_by(name: 'TP. Hồ Chí Minh').id, end_location_id: Location.find_by(name: 'Cà Mau').id)

route_2.stops.create!(
  stop_order: 1,
  location_id: Location.find_by(name: 'TP. Hồ Chí Minh').id,
  is_pickup: true,
  address: 'Bến xe Miền Tây',
  latitude_address: 10.755,
  longitude_address: 106.659,
  time_range: 0
)

route_2.stops.create!(
  stop_order: 2,
  location_id: Location.find_by(name: 'Cần Thơ').id,
  is_pickup: true,
  is_dropoff: true,
  address: 'Bến xe Cần Thơ',
  latitude_address: 10.045,
  longitude_address: 105.746,
  time_range: 70
)

route_2.stops.create!(
  stop_order: 3,
  location_id: Location.find_by(name: 'Sóc Trăng').id,
  is_pickup: false,
  address: 'Bến xe Sóc Trăng',
  latitude_address: 9.596,
  longitude_address: 105.965,
  time_range: 100
)

route_2.stops.create!(
  stop_order: 4,
  location_id: Location.find_by(name: 'Bạc Liêu').id,
  is_dropoff: true,
  address: 'Bến xe Bạc Liêu',
  latitude_address: 9.287,
  longitude_address: 105.349,
  time_range: 190
)

route_2.stops.create!(
  stop_order: 5,
  location_id: Location.find_by(name: 'Cà Mau').id,
  is_dropoff: true,
  address: 'Bến xe Cà Mau',
  latitude_address: 9.175,
  longitude_address: 105.145,
  time_range: 360
)

# Tạo stops cho tuyến Đà Nẵng -> Quảng Nam -> Bình Định -> Khánh Hòa -> Hà Nội
route_3 = Route.find_by(start_location_id: Location.find_by(name: 'Đà Nẵng').id, end_location_id: Location.find_by(name: 'Hà Nội').id)

route_3.stops.create!(
  stop_order: 1,
  location_id: Location.find_by(name: 'Đà Nẵng').id,
  is_pickup: true,
  address: 'Bến xe Đà Nẵng',
  latitude_address: 16.067,
  longitude_address: 108.221,
  time_range: 0
)

route_3.stops.create!(
  stop_order: 2,
  location_id: Location.find_by(name: 'Quảng Nam').id,
  is_pickup: false,
  address: 'Bến xe Quảng Nam',
  latitude_address: 15.607,
  longitude_address: 108.475,
  time_range: 65
)

route_3.stops.create!(
  stop_order: 3,
  location_id: Location.find_by(name: 'Bình Định').id,
  is_pickup: false,
  address: 'Bến xe Bình Định',
  latitude_address: 13.782,
  longitude_address: 109.185,
  time_range: 90
)

route_3.stops.create!(
  stop_order: 4,
  location_id: Location.find_by(name: 'Khánh Hòa').id,
  is_pickup: true,
  is_dropoff: true,
  address: 'Bến xe Khánh Hòa',
  latitude_address: 12.241,
  longitude_address: 109.196,
  time_range: 120
)

route_3.stops.create!(
  stop_order: 5,
  location_id: Location.find_by(name: 'Hà Nội').id,
  is_dropoff: true,
  address: 'Bến xe Mỹ Đình',
  latitude_address: 21.027,
  longitude_address: 105.801,
  time_range: 200
)

# Tạo Stops cho route_4
route_4 = Route.find_by(start_location_id: Location.find_by(name: 'Hà Nội').id, end_location_id: Location.find_by(name: 'Đà Nẵng').id)

route_4.stops.create!(
  stop_order: 1,
  location_id: Location.find_by(name: 'Hà Nội').id,
  is_pickup: true,
  time_range: 0,
  address: 'Bến xe Mỹ Đình',
  latitude_address: 21.027,
  longitude_address: 105.801
)

route_4.stops.create!(
  stop_order: 2,
  location_id: Location.find_by(name: 'Nam Định').id,
  is_pickup: false,
  time_range: 90,
  address: 'Bến xe Nam Định',
  latitude_address: 20.405,
  longitude_address: 106.159
)

route_4.stops.create!(
  stop_order: 3,
  location_id: Location.find_by(name: 'Ninh Bình').id,
  is_dropoff: true,
  time_range: 120,
  address: 'Bến xe Ninh Bình',
  latitude_address: 20.252,
  longitude_address: 105.976
)

route_5 = Route.find_by(start_location_id: Location.find_by(name: 'Hà Nội').id, end_location_id: Location.find_by(name: 'Hải Phòng').id)

# Tạo Stops cho route_5
route_5.stops.create!(
  stop_order: 1,
  location_id: Location.find_by(name: 'Hà Nội').id,
  is_pickup: true,
  time_range: 0,
  address: 'Bến xe Mỹ Đình',
  latitude_address: 21.027,
  longitude_address: 105.801
)

route_5.stops.create!(
  stop_order: 2,
  location_id: Location.find_by(name: 'Hải Phòng').id,
  is_dropoff: true,
  time_range: 180,
  address: 'Bến xe Hải Phòng',
  latitude_address: 20.844,
  longitude_address: 106.691
)

# Tạo Stops cho route_6
route_6 = Route.find_by(start_location_id: Location.find_by(name: 'Hải Phòng').id, end_location_id: Location.find_by(name: 'Hà Nội').id)

route_6.stops.create!(
  stop_order: 1,
  location_id: Location.find_by(name: 'Hải Phòng').id,
  is_pickup: true,
  time_range: 0,
  address: 'Bến xe Hải Phòng',
  latitude_address: 20.844,
  longitude_address: 106.691
)

route_6.stops.create!(
  stop_order: 2,
  location_id: Location.find_by(name: 'Hà Nội').id,
  is_dropoff: true,
  time_range: 180,
  address: 'Bến xe Mỹ Đình',
  latitude_address: 21.027,
  longitude_address: 105.801
)


# Tạo stops cho tuyến Hà Nội -> Nghệ An -> Thanh Hóa
route_7 = Route.find_by(start_location_id: Location.find_by(name: 'Hà Nội').id, end_location_id: Location.find_by(name: 'Thanh Hóa').id)

route_7.stops.create!(
  stop_order: 1,
  location_id: Location.find_by(name: 'Hà Nội').id,
  is_pickup: true,
  time_range: 0,
  address: 'Bến xe Mỹ Đình',
  latitude_address: 21.027,
  longitude_address: 105.801
)

route_7.stops.create!(
  stop_order: 2,
  location_id: Location.find_by(name: 'Nghệ An').id,
  is_pickup: false,
  time_range: 120,
  address: 'Bến xe Nghệ An',
  latitude_address: 19.281,
  longitude_address: 105.831
)

route_7.stops.create!(
  stop_order: 3,
  location_id: Location.find_by(name: 'Thanh Hóa').id,
  is_dropoff: true,
  time_range: 180,
  address: 'Bến xe Thanh Hóa',
  latitude_address: 19.806,
  longitude_address: 105.779
)

route_8 = Route.find_by(start_location_id: Location.find_by(name: 'Thanh Hóa').id, end_location_id: Location.find_by(name: 'Hà Nội').id)

# Tạo Stops cho route_8
route_8.stops.create!(
  stop_order: 1,
  location_id: Location.find_by(name: 'Thanh Hóa').id,
  is_pickup: true,
  time_range: 0,
  address: 'Bến xe Thanh Hóa',
  latitude_address: 19.806,
  longitude_address: 105.779
)

route_8.stops.create!(
  stop_order: 2,
  location_id: Location.find_by(name: 'Nghệ An').id,
  is_pickup: true,
  time_range: 120,
  address: 'Bến xe Nghệ An',
  latitude_address: 19.281,
  longitude_address: 105.831
)

route_8.stops.create!(
  stop_order: 3,
  location_id: Location.find_by(name: 'Hà Nội').id,
  is_dropoff: true,
  time_range: 240,
  address: 'Bến xe Mỹ Đình',
  latitude_address: 21.027,
  longitude_address: 105.801
)

# Tạo stops cho tuyến Đà Nẵng -> Quảng Nam -> Quảng Ngãi -> Bình Định -> Khánh Hòa
route_9 = Route.find_by(start_location_id: Location.find_by(name: 'Đà Nẵng').id, end_location_id: Location.find_by(name: 'Khánh Hòa').id)

route_9.stops.create!(
  stop_order: 1,
  location_id: Location.find_by(name: 'Đà Nẵng').id,
  is_pickup: true,
  time_range: 0,
  address: 'Bến xe Đà Nẵng',
  latitude_address: 16.067,
  longitude_address: 108.221
)

route_9.stops.create!(
  stop_order: 2,
  location_id: Location.find_by(name: 'Quảng Nam').id,
  is_pickup: false,
  time_range: 60,
  address: 'Bến xe Quảng Nam',
  latitude_address: 15.607,
  longitude_address: 108.475
)

route_9.stops.create!(
  stop_order: 3,
  location_id: Location.find_by(name: 'Quảng Ngãi').id,
  is_pickup: false,
  time_range: 120,
  address: 'Bến xe Quảng Ngãi',
  latitude_address: 14.902,
  longitude_address: 108.803
)

route_9.stops.create!(
  stop_order: 4,
  location_id: Location.find_by(name: 'Bình Định').id,
  is_pickup: false,
  time_range: 180,
  address: 'Bến xe Bình Định',
  latitude_address: 13.782,
  longitude_address: 109.185
)

route_9.stops.create!(
  stop_order: 5,
  location_id: Location.find_by(name: 'Khánh Hòa').id,
  is_dropoff: true,
  time_range: 240,
  address: 'Bến xe Khánh Hòa',
  latitude_address: 12.241,
  longitude_address: 109.196
)

route_10 = Route.find_by(start_location_id: Location.find_by(name: 'Khánh Hòa').id, end_location_id: Location.find_by(name: 'Đà Nẵng').id)

# Tạo Stops cho route_10
route_10.stops.create!(
  stop_order: 1,
  location_id: Location.find_by(name: 'Khánh Hòa').id,
  is_pickup: true,
  time_range: 0,
  address: 'Bến xe Khánh Hòa',
  latitude_address: 12.241,
  longitude_address: 109.196
)

route_10.stops.create!(
  stop_order: 2,
  location_id: Location.find_by(name: 'Bình Định').id,
  is_pickup: true,
  time_range: 60,
  address: 'Bến xe Bình Định',
  latitude_address: 13.782,
  longitude_address: 109.185
)

route_10.stops.create!(
  stop_order: 3,
  location_id: Location.find_by(name: 'Quảng Ngãi').id,
  is_pickup: true,
  time_range: 120,
  address: 'Bến xe Quảng Ngãi',
  latitude_address: 14.902,
  longitude_address: 108.803
)

route_10.stops.create!(
  stop_order: 4,
  location_id: Location.find_by(name: 'Quảng Nam').id,
  is_pickup: true,
  time_range: 180,
  address: 'Bến xe Quảng Nam',
  latitude_address: 15.607,
  longitude_address: 108.475
)

route_10.stops.create!(
  stop_order: 5,
  location_id: Location.find_by(name: 'Đà Nẵng').id,
  is_dropoff: true,
  time_range: 240,
  address: 'Bến xe Đà Nẵng',
  latitude_address: 16.067,
  longitude_address: 108.221
)

# Tạo stops cho tuyến Cần Thơ -> Sóc Trăng -> Bạc Liêu -> Cà Mau
route_11 = Route.find_by(start_location_id: Location.find_by(name: 'Cần Thơ').id, end_location_id: Location.find_by(name: 'Cà Mau').id)

# Tạo Stops cho route_11
route_11.stops.create!(
  stop_order: 1,
  location_id: Location.find_by(name: 'Cần Thơ').id,
  is_pickup: true,
  time_range: 0,
  address: 'Bến xe Cần Thơ',
  latitude_address: 10.045,
  longitude_address: 105.746
)

route_11.stops.create!(
  stop_order: 2,
  location_id: Location.find_by(name: 'Sóc Trăng').id,
  is_pickup: false,
  time_range: 60,
  address: 'Bến xe Sóc Trăng',
  latitude_address: 9.596,
  longitude_address: 105.965
)

route_11.stops.create!(
  stop_order: 3,
  location_id: Location.find_by(name: 'Bạc Liêu').id,
  is_pickup: false,
  time_range: 120,
  address: 'Bến xe Bạc Liêu',
  latitude_address: 9.292,
  longitude_address: 105.719
)

route_11.stops.create!(
  stop_order: 4,
  location_id: Location.find_by(name: 'Cà Mau').id,
  is_dropoff: true,
  time_range: 180,
  address: 'Bến xe Cà Mau',
  latitude_address: 9.191,
  longitude_address: 105.159
)

route_12 = Route.find_by(start_location_id: Location.find_by(name: 'Cà Mau').id, end_location_id: Location.find_by(name: 'Cần Thơ').id)

# Tạo Stops cho route_12
route_12.stops.create!(
  stop_order: 1,
  location_id: Location.find_by(name: 'Cà Mau').id,
  is_pickup: true,
  time_range: 0,
  address: 'Bến xe Cà Mau',
  latitude_address: 9.191,
  longitude_address: 105.159
)

route_12.stops.create!(
  stop_order: 2,
  location_id: Location.find_by(name: 'Bạc Liêu').id,
  is_pickup: true,
  time_range: 60,
  address: 'Bến xe Bạc Liêu',
  latitude_address: 9.292,
  longitude_address: 105.719
)

route_12.stops.create!(
  stop_order: 3,
  location_id: Location.find_by(name: 'Sóc Trăng').id,
  is_pickup: true,
  time_range: 120,
  address: 'Bến xe Sóc Trăng',
  latitude_address: 9.596,
  longitude_address: 105.965
)

route_12.stops.create!(
  stop_order: 4,
  location_id: Location.find_by(name: 'Cần Thơ').id,
  is_dropoff: true,
  time_range: 180,
  address: 'Bến xe Cần Thơ',
  latitude_address: 10.045,
  longitude_address: 105.746
)

route_13 = Route.find_by(start_location_id: Location.find_by(name: 'Ninh Bình').id, end_location_id: Location.find_by(name: 'Hà Nội').id)

# Tạo Stops cho route_13
route_13.stops.create!(
  stop_order: 1,
  location_id: Location.find_by(name: 'Ninh Bình').id,
  is_pickup: true,
  time_range: 0,
  address: 'Bến xe Ninh Bình',
  latitude_address: 20.252,
  longitude_address: 105.976
)

route_13.stops.create!(
  stop_order: 2,
  location_id: Location.find_by(name: 'Nam Định').id,
  is_pickup: true,
  time_range: 90,
  address: 'Bến xe Nam Định',
  latitude_address: 20.405,
  longitude_address: 106.159
)

route_13.stops.create!(
  stop_order: 3,
  location_id: Location.find_by(name: 'Hà Nội').id,
  is_dropoff: true,
  time_range: 180,
  address: 'Bến xe Mỹ Đình',
  latitude_address: 21.027,
  longitude_address: 105.801
)
