CREATE TABLE IF NOT EXISTS journeys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  train_number VARCHAR(10) REFERENCES trains(number),
  pnr VARCHAR(15),
  boarding_station VARCHAR(10) REFERENCES stations(code),
  destination_station VARCHAR(10) REFERENCES stations(code),
  travel_date DATE NOT NULL,
  coach VARCHAR(10),
  berth VARCHAR(20),
  class VARCHAR(10),
  status VARCHAR(20) DEFAULT 'upcoming',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_journeys_user ON journeys(user_id);
CREATE INDEX idx_journeys_train ON journeys(train_number);
CREATE INDEX idx_journeys_status ON journeys(status);
CREATE INDEX idx_journeys_travel_date ON journeys(travel_date);
CREATE INDEX idx_journeys_user_status ON journeys(user_id, status);
