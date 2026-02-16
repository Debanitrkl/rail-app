CREATE TABLE IF NOT EXISTS trains (
  number VARCHAR(10) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(50),
  source_station VARCHAR(10) REFERENCES stations(code),
  destination_station VARCHAR(10) REFERENCES stations(code),
  runs_on VARCHAR(7) DEFAULT '1111111',
  avg_speed_kmph INTEGER,
  distance_km INTEGER,
  duration_minutes INTEGER,
  has_pantry BOOLEAN DEFAULT FALSE,
  has_charging BOOLEAN DEFAULT FALSE,
  has_bio_toilet BOOLEAN DEFAULT FALSE,
  has_cctv BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_trains_name ON trains(name);
CREATE INDEX idx_trains_type ON trains(type);
CREATE INDEX idx_trains_source ON trains(source_station);
CREATE INDEX idx_trains_destination ON trains(destination_station);
