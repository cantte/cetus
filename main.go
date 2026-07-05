package main

import (
	"cetus/pkg/logger"
	"cetus/svc/api"
	"context"
	"os"
)

func main() {
	cfg, err := api.Load()

	if err != nil {
		logger.Error("failed to run API", "err", err)
		os.Exit(1)
	}

	err = api.Run(context.Background(), *cfg)

	if err != nil {
		logger.Error("failed to run API", "err", err)
		os.Exit(1)
	}
}
