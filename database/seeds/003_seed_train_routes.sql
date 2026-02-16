-- Howrah Rajdhani Express (12301): HWH -> NDLS
INSERT INTO train_routes (train_number, station_code, stop_number, arrival_time, departure_time, halt_minutes, distance_from_source, day_number, platform) VALUES
('12301', 'HWH', 1, NULL, '16:55', 0, 0, 1, '9'),
('12301', 'MGS', 2, '23:20', '23:25', 5, 679, 1, '3'),
('12301', 'PRYJ', 3, '01:15', '01:20', 5, 842, 2, '4'),
('12301', 'CNB', 4, '03:10', '03:15', 5, 987, 2, '1'),
('12301', 'NDLS', 5, '09:55', NULL, 0, 1447, 2, '16');

-- Mumbai Rajdhani Express (12951): BCT -> NDLS
INSERT INTO train_routes (train_number, station_code, stop_number, arrival_time, departure_time, halt_minutes, distance_from_source, day_number, platform) VALUES
('12951', 'BCT', 1, NULL, '17:40', 0, 0, 1, '5'),
('12951', 'BRC', 2, '21:10', '21:15', 5, 392, 1, '3'),
('12951', 'KOTA', 3, '02:35', '02:40', 5, 860, 2, '1'),
('12951', 'NDLS', 4, '08:35', NULL, 0, 1384, 2, '1');

-- Bhopal Shatabdi (12001): BPL -> NDLS
INSERT INTO train_routes (train_number, station_code, stop_number, arrival_time, departure_time, halt_minutes, distance_from_source, day_number, platform) VALUES
('12001', 'BPL', 1, NULL, '06:00', 0, 0, 1, '1'),
('12001', 'JHS', 2, '08:55', '09:00', 5, 292, 1, '5'),
('12001', 'GWL', 3, '10:24', '10:26', 2, 414, 1, '1'),
('12001', 'AGC', 4, '11:45', '11:50', 5, 534, 1, '3'),
('12001', 'NDLS', 5, '13:40', NULL, 0, 701, 1, '15');

-- New Delhi Shatabdi (12002): NDLS -> BPL
INSERT INTO train_routes (train_number, station_code, stop_number, arrival_time, departure_time, halt_minutes, distance_from_source, day_number, platform) VALUES
('12002', 'NDLS', 1, NULL, '06:00', 0, 0, 1, '15'),
('12002', 'AGC', 2, '07:55', '08:00', 5, 195, 1, '3'),
('12002', 'GWL', 3, '09:17', '09:19', 2, 316, 1, '1'),
('12002', 'JHS', 4, '10:30', '10:35', 5, 409, 1, '5'),
('12002', 'BPL', 5, '13:40', NULL, 0, 701, 1, '1');

-- Vande Bharat (22435): NDLS -> LKO
INSERT INTO train_routes (train_number, station_code, stop_number, arrival_time, departure_time, halt_minutes, distance_from_source, day_number, platform) VALUES
('22435', 'NDLS', 1, NULL, '06:00', 0, 0, 1, '1'),
('22435', 'CNB', 2, '10:15', '10:20', 5, 440, 1, '3'),
('22435', 'LKO', 3, '11:25', NULL, 0, 511, 1, '1');

-- Vande Bharat (22436): LKO -> NDLS
INSERT INTO train_routes (train_number, station_code, stop_number, arrival_time, departure_time, halt_minutes, distance_from_source, day_number, platform) VALUES
('22436', 'LKO', 1, NULL, '14:30', 0, 0, 1, '1'),
('22436', 'CNB', 2, '15:30', '15:35', 5, 71, 1, '3'),
('22436', 'NDLS', 3, '19:55', NULL, 0, 511, 1, '1');

-- KSR Bengaluru Rajdhani (22691): SBC -> NDLS
INSERT INTO train_routes (train_number, station_code, stop_number, arrival_time, departure_time, halt_minutes, distance_from_source, day_number, platform) VALUES
('22691', 'SBC', 1, NULL, '20:00', 0, 0, 1, '1'),
('22691', 'SC', 2, '05:15', '05:25', 10, 572, 2, '1'),
('22691', 'NGP', 3, '12:10', '12:15', 5, 1123, 2, '3'),
('22691', 'BPL', 4, '17:30', '17:35', 5, 1466, 2, '2'),
('22691', 'AGC', 5, '00:15', '00:20', 5, 2062, 3, '3'),
('22691', 'NDLS', 6, '06:00', NULL, 0, 2444, 3, '16');

-- Tamil Nadu Express (12621): MAS -> NDLS
INSERT INTO train_routes (train_number, station_code, stop_number, arrival_time, departure_time, halt_minutes, distance_from_source, day_number, platform) VALUES
('12621', 'MAS', 1, NULL, '22:00', 0, 0, 1, '5'),
('12621', 'PRYJ', 2, '16:00', '16:10', 10, 1533, 2, '6'),
('12621', 'CNB', 3, '18:40', '18:45', 5, 1696, 2, '2'),
('12621', 'AGC', 4, '23:55', '00:00', 5, 1987, 3, '1'),
('12621', 'NDLS', 5, '07:15', NULL, 0, 2182, 3, '7');

-- Karnataka Express (12627): SBC -> NDLS
INSERT INTO train_routes (train_number, station_code, stop_number, arrival_time, departure_time, halt_minutes, distance_from_source, day_number, platform) VALUES
('12627', 'SBC', 1, NULL, '21:30', 0, 0, 1, '3'),
('12627', 'SC', 2, '08:00', '08:15', 15, 572, 2, '5'),
('12627', 'NGP', 3, '16:30', '16:40', 10, 1123, 2, '2'),
('12627', 'BPL', 4, '22:45', '22:55', 10, 1466, 2, '1'),
('12627', 'JHS', 5, '02:00', '02:10', 10, 1758, 3, '3'),
('12627', 'AGC', 6, '04:50', '05:00', 10, 2168, 3, '1'),
('12627', 'NDLS', 7, '08:30', NULL, 0, 2627, 3, '10');

-- Kerala Express (12625): TVC -> NDLS
INSERT INTO train_routes (train_number, station_code, stop_number, arrival_time, departure_time, halt_minutes, distance_from_source, day_number, platform) VALUES
('12625', 'TVC', 1, NULL, '11:15', 0, 0, 1, '1'),
('12625', 'SBC', 2, '00:45', '01:00', 15, 840, 2, '2'),
('12625', 'SC', 3, '12:00', '12:15', 15, 1412, 2, '1'),
('12625', 'NGP', 4, '21:45', '22:00', 15, 1963, 2, '4'),
('12625', 'BPL', 5, '04:00', '04:10', 10, 2306, 3, '3'),
('12625', 'AGC', 6, '14:30', '14:40', 10, 2654, 3, '1'),
('12625', 'NDLS', 7, '17:30', NULL, 0, 3032, 3, '15');

-- Golden Temple Mail (12903): BCT -> NDLS
INSERT INTO train_routes (train_number, station_code, stop_number, arrival_time, departure_time, halt_minutes, distance_from_source, day_number, platform) VALUES
('12903', 'BCT', 1, NULL, '21:30', 0, 0, 1, '3'),
('12903', 'BRC', 2, '01:30', '01:35', 5, 392, 2, '1'),
('12903', 'KOTA', 3, '09:10', '09:15', 5, 860, 2, '3'),
('12903', 'NDLS', 4, '17:30', NULL, 0, 1543, 2, '7');

-- New Delhi Rajdhani Express (12302): NDLS -> HWH
INSERT INTO train_routes (train_number, station_code, stop_number, arrival_time, departure_time, halt_minutes, distance_from_source, day_number, platform) VALUES
('12302', 'NDLS', 1, NULL, '16:55', 0, 0, 1, '16'),
('12302', 'CNB', 2, '22:25', '22:30', 5, 460, 1, '1'),
('12302', 'PRYJ', 3, '00:35', '00:40', 5, 605, 2, '4'),
('12302', 'MGS', 4, '02:45', '02:50', 5, 768, 2, '3'),
('12302', 'HWH', 5, '09:55', NULL, 0, 1447, 2, '9');

-- Mumbai Rajdhani Return (12952): NDLS -> BCT
INSERT INTO train_routes (train_number, station_code, stop_number, arrival_time, departure_time, halt_minutes, distance_from_source, day_number, platform) VALUES
('12952', 'NDLS', 1, NULL, '16:35', 0, 0, 1, '1'),
('12952', 'KOTA', 2, '22:45', '22:50', 5, 524, 1, '1'),
('12952', 'BRC', 3, '04:30', '04:35', 5, 992, 2, '3'),
('12952', 'BCT', 4, '08:35', NULL, 0, 1384, 2, '5');

-- Sealdah Duronto (12259): NDLS -> HWH
INSERT INTO train_routes (train_number, station_code, stop_number, arrival_time, departure_time, halt_minutes, distance_from_source, day_number, platform) VALUES
('12259', 'NDLS', 1, NULL, '20:15', 0, 0, 1, '8'),
('12259', 'HWH', 2, '13:15', NULL, 0, 1447, 2, '7')
ON CONFLICT DO NOTHING;
