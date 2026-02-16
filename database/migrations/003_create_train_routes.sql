CREATE TABLE IF NOT EXISTS train_routes (
  id SERIAL PRIMARY KEY,
  train_number VARCHAR(10) REFERENCES trains(number),
  station_code VARCHAR(10) REFERENCES stations(code),
  stop_number INTEGER NOT NULL,
  arrival_time TIME,
  departure_time TIME,
  halt_minutes INTEGER DEFAULT 0,
  distance_from_source INTEGER DEFAULT 0,
  day_number INTEGER DEFAULT 1,
  platform VARCHAR(5),
  UNIQUE(train_number, stop_number)
);

CREATE INDEX idx_train_routes_train ON train_routes(train_number);
CREATE INDEX idx_train_routes_station ON train_routes(station_code);
CREATE INDEX idx_train_routes_stop ON train_routes(train_number, stop_number);
