package config

import (
	"os"
	"strconv"
)

type Config struct {
	ParseableURL      string
	ParseableUser     string
	ParseablePassword string
	ValkeyHost        string
	ValkeyPort        int
	NTESBaseURL       string
	PollInterval      int
	MockData          bool
	PostgresHost      string
	PostgresPort      int
	PostgresUser      string
	PostgresPassword  string
	PostgresDB        string
}

func Load() *Config {
	return &Config{
		ParseableURL:      getEnv("PARSEABLE_URL", "http://localhost:8000"),
		ParseableUser:     getEnv("PARSEABLE_USER", "admin"),
		ParseablePassword: getEnv("PARSEABLE_PASSWORD", "admin"),
		ValkeyHost:        getEnv("VALKEY_HOST", "localhost"),
		ValkeyPort:        getEnvInt("VALKEY_PORT", 6379),
		NTESBaseURL:       getEnv("NTES_BASE_URL", "https://enquiry.indianrail.gov.in"),
		PollInterval:      getEnvInt("INGESTION_POLL_INTERVAL", 60),
		MockData:          getEnvBool("MOCK_DATA", true),
		PostgresHost:      getEnv("POSTGRES_HOST", "localhost"),
		PostgresPort:      getEnvInt("POSTGRES_PORT", 5432),
		PostgresUser:      getEnv("POSTGRES_USER", "rail"),
		PostgresPassword:  getEnv("POSTGRES_PASSWORD", "rail_secret_2024"),
		PostgresDB:        getEnv("POSTGRES_DB", "rail"),
	}
}

func getEnv(key, defaultVal string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return defaultVal
}

func getEnvInt(key string, defaultVal int) int {
	if val := os.Getenv(key); val != "" {
		if i, err := strconv.Atoi(val); err == nil {
			return i
		}
	}
	return defaultVal
}

func getEnvBool(key string, defaultVal bool) bool {
	if val := os.Getenv(key); val != "" {
		if b, err := strconv.ParseBool(val); err == nil {
			return b
		}
	}
	return defaultVal
}
