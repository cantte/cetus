package api

import (
	"cetus/pkg/buildinfo"
	"cetus/pkg/db"
	"cetus/pkg/logger"
	"cetus/pkg/otel"
	"cetus/pkg/prometheus"
	"cetus/pkg/prometheus/lazy"
	"cetus/pkg/runner"
	"cetus/svc/api/routes"
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	promclient "github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/collectors"
	"github.com/prometheus/common/version"
)

func Run(ctx context.Context, cfg Config) error {
	if cfg.Observability.Logging != nil {
		logger.SetSampler(logger.TailSampler{
			SlowThreshold: cfg.Observability.Logging.SlowThreshold,
			SampleRate:    cfg.Observability.Logging.SampleRate,
		})
	}

	logger.AddBaseAttrs(slog.GroupAttrs("instance",
		slog.String("id", cfg.InstanceID),
		slog.String("region", cfg.Region),
		slog.String("version", buildinfo.Version),
	))

	reg := promclient.NewRegistry()
	reg.MustRegister(collectors.NewGoCollector())
	//nolint:exhaustruct
	reg.MustRegister(collectors.NewProcessCollector(collectors.ProcessCollectorOpts{}))
	lazy.SetRegistry(reg)
	buildinfo.RegisterBuildInfoMetrics("api")

	var err error
	var shutdownGrafana func(context.Context) error
	if cfg.Observability.Tracing != nil {
		logger.Info("cfg.Observability.Tracing")
		shutdownGrafana, err = otel.InitGrafana(ctx, otel.Config{
			Application:        "api",
			Version:            version.Version,
			InstanceID:         cfg.InstanceID,
			CloudRegion:        cfg.Region,
			TraceSampleRate:    cfg.Observability.Tracing.SampleRate,
			PrometheusGatherer: reg,
		})

		if err != nil {
			return fmt.Errorf("unable to init grafana: %w", err)
		}
	}

	r := runner.New()
	defer r.Recover()

	r.DeferCtx(shutdownGrafana)

	database, err := db.New(db.Config{
		PrimaryDSN: cfg.DatabaseURL,
	})
	if err != nil {
		return fmt.Errorf("unable to create db: %w", err)
	}

	r.Defer(database.Close)

	if cfg.Observability.Metrics != nil {
		logger.Info("cfg.Observability.Metrics")
		prom, promErr := prometheus.NewWithRegistry(reg)
		if promErr != nil {
			return fmt.Errorf("unable to start prometheus: %w", promErr)
		}

		promListener, listenErr := net.Listen("tcp", fmt.Sprintf(":%d", cfg.Observability.Metrics.PrometheusPort))
		if listenErr != nil {
			return fmt.Errorf("unable to listen on port %d: %w", cfg.Observability.Metrics.PrometheusPort, listenErr)
		}

		r.DeferCtx(prom.Shutdown)
		r.Go(func(ctx context.Context) error {
			serveErr := prom.Serve(promListener)
			if serveErr != nil && !errors.Is(serveErr, context.Canceled) {
				return fmt.Errorf("prometheus server failed: %w", serveErr)
			}
			return nil
		})
	}

	g := gin.New()

	g.Use(
		gin.Recovery(),
	)

	routes.Register(g, &routes.Services{
		Database: database,
	})

	// Server with graceful shutdown
	srv := &http.Server{
		Addr:         cfg.Port,
		Handler:      g,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
	}

	r.DeferCtx(srv.Shutdown)

	r.Go(func(ctx context.Context) error {
		logger.Info("server starting", "port", cfg.Port)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			return fmt.Errorf("server failed: %w", err)
		}

		return nil
	})

	// Wait for either OS signals or context cancellation, then shutdown
	if err := r.Wait(ctx, runner.WithTimeout(time.Minute)); err != nil {
		logger.Error("Shutdown failed", "error", err)
		return fmt.Errorf("shutdown failed: %w", err)
	}

	logger.Info("API server shut down successfully")

	return nil
}
