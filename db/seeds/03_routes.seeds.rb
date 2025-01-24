locations = Location.all
ca_mau = locations.find { |location| location.name == "Cà Mau" }
tp_ho_chi_minh = locations.find { |location| location.name == "TP. Hồ Chí Minh" }
da_nang = locations.find { |location| location.name == "Đà Nẵng" }
ha_noi = locations.find { |location| location.name == "Hà Nội" }
lao_cai = locations.find { |location| location.name == "Lào Cai" }
hai_phong = locations.find { |location| location.name == "Hải Phòng" }
thanh_hoa = locations.find { |location| location.name == "Thanh Hóa" }
khanh_hoa = locations.find { |location| location.name == "Khánh Hòa" }
can_tho = locations.find { |location| location.name == "Cần Thơ" }
tien_giang = locations.find { |location| location.name == "Tiền Giang" }
hau_giang = locations.find { |location| location.name == "Hậu Giang" }
long_an = locations.find { |location| location.name == "Long An" }
tra_vinh = locations.find { |location| location.name == "Trà Vinh" }
vung_tau = locations.find { |location| location.name == "Bà Rịa - Vũng Tàu" }
an_giang = locations.find { |location| location.name == "An Giang" }
binh_thuan = locations.find { |location| location.name == "Bình Thuận" }
ninh_thuan = locations.find { |location| location.name == "Ninh Thuận" }
kien_giang = locations.find { |location| location.name == "Kiên Giang" }
bac_lieu = locations.find { |location| location.name == "Bạc Liêu" }
nghe_an = locations.find { |location| location.name == "Nghệ An" }

# Thêm dữ liệu vào bảng routes
ca_mau.start_routes.create(end_location: tp_ho_chi_minh)
tp_ho_chi_minh.start_routes.create(end_location: ca_mau)
da_nang.start_routes.create(end_location: ha_noi)
ha_noi.start_routes.create(end_location: da_nang)
ha_noi.start_routes.create(end_location: lao_cai)
lao_cai.start_routes.create(end_location: ha_noi)
ha_noi.start_routes.create(end_location: hai_phong)
ha_noi.start_routes.create(end_location: thanh_hoa)
hai_phong.start_routes.create(end_location: ha_noi)
thanh_hoa.start_routes.create(end_location: ha_noi)
da_nang.start_routes.create(end_location: khanh_hoa)
khanh_hoa.start_routes.create(end_location: da_nang)
tp_ho_chi_minh.start_routes.create(end_location: can_tho)
can_tho.start_routes.create(end_location: tp_ho_chi_minh)
can_tho.start_routes.create(end_location: ca_mau)
ca_mau.start_routes.create(end_location: can_tho)
tien_giang.start_routes.create(end_location: hau_giang)
long_an.start_routes.create(end_location: tra_vinh)
tp_ho_chi_minh.start_routes.create(end_location: vung_tau)
tp_ho_chi_minh.start_routes.create(end_location: an_giang)
binh_thuan.start_routes.create(end_location: ninh_thuan)
ninh_thuan.start_routes.create(end_location: binh_thuan)
binh_thuan.start_routes.create(end_location: khanh_hoa)
khanh_hoa.start_routes.create(end_location: binh_thuan)
ninh_thuan.start_routes.create(end_location: tp_ho_chi_minh)
tp_ho_chi_minh.start_routes.create(end_location: ninh_thuan)
tp_ho_chi_minh.start_routes.create(end_location: kien_giang)
kien_giang.start_routes.create(end_location: tp_ho_chi_minh)
kien_giang.start_routes.create(end_location: bac_lieu)
bac_lieu.start_routes.create(end_location: kien_giang)
thanh_hoa.start_routes.create(end_location: nghe_an)
