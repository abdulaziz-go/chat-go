package main

import (
	"errors"
	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/joho/godotenv"
	"log"
	"os"
	"time"
)

const (
	_defaultAttempts = 20
	_defaultTimeout  = time.Second
)

func init() {
	err := godotenv.Load(".env")
	if err != nil {
		log.Printf("not found env %v", err)
		return
	}
	dbUrl := os.Getenv("DB_URL")
	if dbUrl == "" {
		log.Println("DB_URL is not set in .env file")
		return
	}
	runMigrations(dbUrl)
}

func runMigrations(dbUrl string) {
	var (
		attempts = _defaultAttempts
		err      error
		m        *migrate.Migrate
	)

	for attempts > 0 {
		m, err = migrate.New("file://migrations", dbUrl)
		if err == nil {
			break
		}

		log.Printf("Migrate: postgres is trying to connect, attempts left: %d", attempts)
		time.Sleep(_defaultTimeout)
		attempts--
	}
	if err != nil {
		log.Fatalf("Migrate: postgres connect error: %s", err)
	}

	defer func() {
		if _, err := m.Close(); err != nil {
			log.Fatalf("Migrate: close error: %s", err)
		}
	}()

	err = m.Up()
	if err != nil && !errors.Is(err, migrate.ErrNoChange) {
		log.Fatalf("Migrate: up error: %s", err)
	}

	if errors.Is(err, migrate.ErrNoChange) {
		log.Printf("Migrate: no change")
		return
	}

	log.Printf("Migrate: up success")
}
