package domain

import (
	"fmt"
	"time"
)

// Status enum-like string
type TaskStatus string

const (
	StatusTodo       TaskStatus = "todo"
	StatusInProgress TaskStatus = "in_progress"
	StatusDone       TaskStatus = "done"
)

// Domain Struct
type Task struct {
	ID        string     `json:"id"`
	Title     string     `json:"title"`
	Status    TaskStatus `json:"status"`
	CreatedAt time.Time  `json:"created_at"`
}

// Custom Error: TaskNotFoundError
type TaskNotFoundError struct {
	TaskID string
}

// Implement the built-in Go error interface: Error() string
func (e *TaskNotFoundError) Error() string {
	return fmt.Sprintf("task with ID '%s' not found", e.TaskID)
}

// Custom Error: ValidationError
type ValidationError struct {
	Field   string
	Message string
}

func (e *ValidationError) Error() string {
	return fmt.Sprintf("validation failed on field '%s': %s", e.Field, e.Message)
}
