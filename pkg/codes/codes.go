package codes

// URN is a string type for error code constants
type URN string

const (
	ErrorsNotFound        URN = "err:user:not_found"
	ErrorsUnauthorized    URN = "err:user:unauthorized"
	ErrorsForbidden       URN = "err:user:forbidden"
	ErrorsConflict        URN = "err:user:conflict"
	ErrorsTooManyRequests URN = "err:user:too_many_requests"
	ErrorsBadRequest      URN = "err:user:bad_request"

	// Internal

	// UnexpectedError represents an unhandled or unexpected error condition.
	AppErrorsInternalUnexpectedError URN = "err:application:unexpected_error"
	// ServiceUnavailable indicates a service is temporarily unavailable.
	AppErrorsInternalServiceUnavailable URN = "err:application:service_unavailable"
)
