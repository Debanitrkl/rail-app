CREATE TABLE IF NOT EXISTS user_devices (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  device_token VARCHAR(500) NOT NULL,
  platform VARCHAR(10) DEFAULT 'ios',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_user_devices_user ON user_devices(user_id);
CREATE INDEX idx_user_devices_token ON user_devices(device_token);
