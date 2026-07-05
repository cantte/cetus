package routes

import (
	"cetus/pkg/server"
	"cetus/svc/api/routes/v1/hello_world"

	"github.com/gin-gonic/gin"
)

// Register mounts all API route handlers onto the provided Gin engine.
//
// It applies the following middleware layers in order:
//   - CORS (global) — allows all origins; required before route matching so
//     that OPTIONS preflight requests are handled correctly.
//   - JWT auth — all v1 routes require a valid bearer token issued by the
//     auth provider.
//   - Admin role guard — routes under /v1/admin require the JWT claim
//     role="admin"; others receive 403 Forbidden.
//   - WhatsApp signature — webhook processing routes validate the
//     X-Hub-Signature-256 header against [Services.AppSecret].
//
// Routes are registered via [RegisterRoute] which reads the method and path
// directly from each handler, keeping routing declarations co-located with
// handler logic.
func Register(g *gin.Engine, svc *Services) {
	RegisterRoute(g, &hello_world.Handler{})
}

// RegisterRoute registers a single [Route] on the given router group.
// It delegates to [gin.IRoutes.Handle] using the method and path reported by
// the route itself, so each handler is self-describing and no central routing
// table is needed.
func RegisterRoute(g gin.IRoutes, route server.Route) {
	server.RegisterRoute(g, route)
}