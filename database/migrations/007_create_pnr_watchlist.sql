CREATE TABLE IF NOT EXISTS pnr_watchlist (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  pnr VARCHAR(15) NOT NULL,
  train_number VARCHAR(10),
  travel_date DATE,
  last_status JSONB,
  last_checked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, pnr)
);

CREATE INDEX idx_pnr_watchlist_user ON pnr_watchlist(user_id);
CREATE INDEX idx_pnr_watchlist_pnr ON pnr_watchlist(pnr);
