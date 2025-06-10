MIGRATIONS_DIR = migrations
MIGRATE_TOOL = migrate
DB_URL = postgres://postgres:postgres@localhost:5432/chatdb?sslmode=disable

.PHONY: all run build test migrate-up migrate-down migrate-new docker-up docker-down

all: run

run:
	go run ./cmd/main.go

build:
	go build -o chat-service ./cmd

test:
	go test ./...

migrate-up:
	$(MIGRATE_TOOL) -path $(MIGRATIONS_DIR) -database "$(DB_URL)" up

migrate-down:
	$(MIGRATE_TOOL) -path $(MIGRATIONS_DIR) -database "$(DB_URL)" down 1

migrate-new:
	@read -p "Enter migration name: " name; \
	migrate create -ext sql -dir $(MIGRATIONS_DIR) $$name