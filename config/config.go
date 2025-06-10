package config

import (
	"fmt"
	"github.com/ilyakaznacheev/cleanenv"
	"github.com/joho/godotenv"
)

type (
	Config struct {
		App  `env:"app"`
		HTTP `env:"http"`
		Log  `env:"logger"`
		PG   `env:"postgres"`
		Nats `env:"nats"`
	}

	App struct {
		Name    string `env-required:"true" env:"APP_NAME"`
		Version string `env-required:"true" env:"APP_VERSION"`
	}

	HTTP struct {
		Port string `env-required:"true" env:"HTTP_PORT"`
	}

	Log struct {
		Level string `env-required:"true" env:"LOG_LEVEL"`
	}

	PG struct {
		URL string `env-required:"true" env:"DB_URL"`
	}

	Nats struct {
		URL string `env-required:"true" env:"NATS_URL"`
	}
)

func NewConfig() (*Config, error) {
	cfg := &Config{}

	if err := godotenv.Load(".env"); err != nil {
		return nil, fmt.Errorf("error loading .env file: %w", err)
	}

	if err := cleanenv.ReadEnv(cfg); err != nil {
		return nil, fmt.Errorf("error reading env vars: %w", err)
	}

	return cfg, nil
}
