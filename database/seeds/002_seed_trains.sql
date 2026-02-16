INSERT INTO trains (number, name, type, source_station, destination_station, runs_on, avg_speed_kmph, distance_km, duration_minutes, has_pantry, has_charging, has_bio_toilet, has_cctv) VALUES
('12301', 'Howrah Rajdhani Express', 'Rajdhani', 'HWH', 'NDLS', '1111111', 82, 1447, 1055, TRUE, TRUE, TRUE, TRUE),
('12302', 'New Delhi Rajdhani Express', 'Rajdhani', 'NDLS', 'HWH', '1111111', 82, 1447, 1055, TRUE, TRUE, TRUE, TRUE),
('12951', 'Mumbai Rajdhani Express', 'Rajdhani', 'BCT', 'NDLS', '1111111', 85, 1384, 975, TRUE, TRUE, TRUE, TRUE),
('12952', 'New Delhi Rajdhani Express', 'Rajdhani', 'NDLS', 'BCT', '1111111', 85, 1384, 975, TRUE, TRUE, TRUE, TRUE),
('12002', 'New Delhi Shatabdi Express', 'Shatabdi', 'NDLS', 'BPL', '1111110', 92, 701, 460, TRUE, TRUE, TRUE, FALSE),
('12001', 'Bhopal Shatabdi Express', 'Shatabdi', 'BPL', 'NDLS', '1111110', 92, 701, 460, TRUE, TRUE, TRUE, FALSE),
('22691', 'KSR Bengaluru Rajdhani Express', 'Rajdhani', 'SBC', 'NDLS', '0101010', 68, 2444, 2160, TRUE, TRUE, TRUE, TRUE),
('22692', 'Bengaluru Rajdhani Express', 'Rajdhani', 'NDLS', 'SBC', '0010101', 68, 2444, 2160, TRUE, TRUE, TRUE, TRUE),
('12259', 'Sealdah Duronto Express', 'Duronto', 'NDLS', 'HWH', '0010100', 85, 1447, 1020, TRUE, TRUE, TRUE, FALSE),
('22435', 'Vande Bharat Express', 'Vande Bharat', 'NDLS', 'LKO', '1111110', 95, 511, 325, TRUE, TRUE, TRUE, TRUE),
('22436', 'Vande Bharat Express', 'Vande Bharat', 'LKO', 'NDLS', '1111110', 95, 511, 325, TRUE, TRUE, TRUE, TRUE),
('12903', 'Golden Temple Mail', 'Superfast', 'BCT', 'NDLS', '1111111', 62, 1543, 1500, TRUE, TRUE, TRUE, FALSE),
('12627', 'Karnataka Express', 'Superfast', 'SBC', 'NDLS', '1111111', 56, 2627, 2820, TRUE, TRUE, TRUE, FALSE),
('12621', 'Tamil Nadu Express', 'Superfast', 'MAS', 'NDLS', '1111111', 59, 2182, 2115, TRUE, TRUE, TRUE, FALSE),
('12625', 'Kerala Express', 'Superfast', 'TVC', 'NDLS', '1111111', 55, 3032, 3255, TRUE, TRUE, TRUE, FALSE)
ON CONFLICT (number) DO NOTHING;
