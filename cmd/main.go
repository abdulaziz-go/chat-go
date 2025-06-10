package main

import (
	"fmt"
	"log"
	"tenant-chat-service/config"
)

func main() {
	cfg, err := config.NewConfig()
	if err != nil {
		log.Fatalf(fmt.Sprintf("error while loading cfg %v", err))
	}

}
