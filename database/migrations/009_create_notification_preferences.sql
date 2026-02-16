CREATE TABLE IF NOT EXISTS notification_preferences (
  user_id UUID PRIMARY KEY REFERENCES users(id),
  delay_alerts BOOLEAN DEFAULT TRUE,
  platform_changes BOOLEAN DEFAULT TRUE,
  pnr_updates BOOLEAN DEFAULT TRUE,
  departure_reminder BOOLEAN DEFAULT TRUE,
  reminder_minutes_before INTEGER DEFAULT 60
);
