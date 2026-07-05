package api

import (
	"context"
	"time"

	"github.com/joho/godotenv"
	"github.com/sethvargo/go-envconfig"
)

// LoggingConfig controls log sampling. Events faster than SlowThreshold are
// emitted with probability SampleRate; events at or above the threshold are
// always emitted.
type LoggingConfig struct {
	// SampleRate is the probability (0.0–1.0) of emitting a fast log event.
	// Set to 1.0 to log everything.
	SampleRate float64 `env:"LOG_SAMPLE_RATE, default=1.0"`

	// SlowThreshold is the duration above which a request is always logged
	// regardless of SampleRate.
	SlowThreshold time.Duration `env:"LOG_SLOW_THRESHOLD, default=5s"`
}

// TracingConfig controls OpenTelemetry tracing and metrics export.
// SampleRate determines what fraction of traces are exported; the rest are dropped
// to reduce storage costs and processing overhead.
type TracingConfig struct {

	// SampleRate is the probability (0.0–1.0) that a trace is sampled.
	SampleRate float64 `env:"LOG_SAMPLE_RATE, default=1.0"`
}

// MetricsConfig controls Prometheus metrics exposition.
type MetricsConfig struct {
	// PrometheusPort is the TCP port where Prometheus-compatible metrics are served.
	// Set to 0 to disable metrics exposure.
	PrometheusPort int `env:"PROMETHEUS_PORT, default=9090"`
}

type Observability struct {
	Tracing *TracingConfig
	Logging *LoggingConfig
	Metrics *MetricsConfig
}

// Config holds all runtime configuration values for the API server,
// populated from environment variables (or a .env file).
type Config struct {
	// InstanceID identifies this particular API server instance.
	InstanceID string `env:"INSTANCE_ID"`
	// Region is the geographic region identifier (e.g. "us-east-1", "eu-west-1").
	Region string `env:"REGION"`
	// DatabaseURL is the connection string for the PostgreSQL database (DATABASE_URL).
	DatabaseURL string `env:"DATABASE_URL"`
	// RedisURL is the connection string for the Redis instance (REDIS_URL)
	RedisURL string `env:"REDIS_URL"`
	// Port is the address the HTTP server listens on (PORT). Defaults to ":8080".
	Port          string `env:"PORT, default=:8080"`
	Observability Observability
	// Environment can be sandbox or production
	Environment string `env:"ENVIRONMENT, default=production"`
}

// Load reads configuration from a .env file if present, then falls back
// to the process environment. Fields without defaults will cause the process to exit if
// their corresponding environment variable is not set.
func Load() (*Config, error) {
	// Load .env only for local/dev. In prod, env vars already exist.
	_ = godotenv.Load()

	var cfg Config

	if err := envconfig.Process(context.Background(), &cfg); err != nil {
		return nil, err
	}

	return &cfg, nil
}
