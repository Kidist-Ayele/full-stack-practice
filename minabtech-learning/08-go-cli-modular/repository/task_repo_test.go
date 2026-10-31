package repository

import (
	"errors"
	"testing"
	"time"
	"taskcli/domain"
)

func TestSaveAndFindTask(t *testing.T) {
	repo := NewInMemoryTaskRepo()

	testTask := &domain.Task{
		ID:        "task-101",
		Title:     "Build Go CLI",
		Status:    domain.StatusTodo,
		CreatedAt: time.Now(),
	}

	// 1. Test Save
	err := repo.Save(testTask)
	if err != nil {
		t.Fatalf("expected no error saving task, got: %v", err)
	}

	// 2. Test FindByID
	found, err := repo.FindByID("task-101")
	if err != nil {
		t.Fatalf("expected to find task-101, got error: %v", err)
	}

	if found.Title != "Build Go CLI" {
		t.Errorf("expected title 'Build Go CLI', got '%s'", found.Title)
	}
}

func TestTaskNotFoundCustomError(t *testing.T) {
	repo := NewInMemoryTaskRepo()

	// Try finding non-existent ID
	_, err := repo.FindByID("non-existent-id")
	if err == nil {
		t.Fatal("expected error, got nil")
	}

	// Verify custom error type matching using errors.As
	var notFoundErr *domain.TaskNotFoundError
	if !errors.As(err, &notFoundErr) {
		t.Fatalf("expected TaskNotFoundError, got %T: %v", err, err)
	}

	if notFoundErr.TaskID != "non-existent-id" {
		t.Errorf("expected task ID 'non-existent-id', got '%s'", notFoundErr.TaskID)
	}
}

func TestValidationEmptyTitle(t *testing.T) {
	repo := NewInMemoryTaskRepo()

	invalidTask := &domain.Task{
		ID:    "task-bad",
		Title: "", // Empty!
	}

	err := repo.Save(invalidTask)
	if err == nil {
		t.Fatal("expected validation error for empty title, got nil")
	}

	var valErr *domain.ValidationError
	if !errors.As(err, &valErr) {
		t.Fatalf("expected ValidationError, got %T: %v", err, err)
	}
}
