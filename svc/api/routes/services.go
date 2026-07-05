package routes

import (
	"cetus/pkg/db"
)

// Services aggregates all dependencies required by API route handlers. It acts
// as a dependency injection container, allowing [Register] to wire up handlers
// without exposing individual dependencies throughout the codebase.
//
// This struct is constructed during server startup and passed to [Register].
// All fields except the optional configuration fields
// must be non-nil for the API to function correctly.
type Services struct {
	// Database provides access to the primary database
	Database db.Database

	// Environment can be sandbox or production, used to filter active plans in the database
	Environment string
}
