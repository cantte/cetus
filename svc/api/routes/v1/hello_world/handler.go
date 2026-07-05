package hello_world

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type Handler struct {
}

func (h *Handler) Method() string {
	return http.MethodGet
}

func (h *Handler) Path() string {
	return "/v1/hello-world"
}

func (h *Handler) Handle(c *gin.Context) error {
	c.JSON(http.StatusOK, gin.H{"message": "Hello"})
	return nil
}
