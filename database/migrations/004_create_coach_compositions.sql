CREATE TABLE IF NOT EXISTS coach_compositions (
  id SERIAL PRIMARY KEY,
  train_number VARCHAR(10) REFERENCES trains(number),
  position INTEGER NOT NULL,
  coach_label VARCHAR(10) NOT NULL,
  coach_type VARCHAR(20) NOT NULL,
  total_berths INTEGER DEFAULT 0,
  UNIQUE(train_number, position)
);

CREATE INDEX idx_coach_compositions_train ON coach_compositions(train_number);
