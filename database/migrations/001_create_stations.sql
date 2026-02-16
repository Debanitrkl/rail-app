CREATE TABLE IF NOT EXISTS stations (
  code VARCHAR(10) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  zone VARCHAR(50),
  division VARCHAR(100),
  state VARCHAR(100),
  latitude DECIMAL(10, 7),
  longitude DECIMAL(10, 7),
  platforms_count INTEGER DEFAULT 0,
  has_wifi BOOLEAN DEFAULT FALSE,
  has_parking BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_stations_name ON stations(name);
CREATE INDEX idx_stations_state ON stations(state);
CREATE INDEX idx_stations_zone ON stations(zone);
