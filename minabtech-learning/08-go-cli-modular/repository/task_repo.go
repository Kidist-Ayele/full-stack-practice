package repository

import (
	"sync"
	"taskcli/domain"
)

// TaskRepository interface defines the contract
type TaskRepository interface {
	Save(task *domain.Task) error
	FindByID(id string) (*domain.Task, error)
	FindAll() ([]domain.Task, error)
	Delete(id string) error
}

// InMemoryTaskRepo implements TaskRepository using a map
type InMemoryTaskRepo struct {
	mu    sync.RWMutex
	tasks map[string]domain.Task
}

// NewInMemoryTaskRepo constructor
func NewInMemoryTaskRepo() *InMemoryTaskRepo {
	return &InMemoryTaskRepo{
		tasks: make(map[string]domain.Task),
	}
}

func (r *InMemoryTaskRepo) Save(task *domain.Task) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	if task.Title == "" {
		return &domain.ValidationError{Field: "Title", Message: "title cannot be empty"}
	}

	r.tasks[task.ID] = *task
	return nil
}

func (r *InMemoryTaskRepo) FindByID(id string) (*domain.Task, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	task, exists := r.tasks[id]
	if !exists {
		return nil, &domain.TaskNotFoundError{TaskID: id}
	}
	return &task, nil
}

func (r *InMemoryTaskRepo) FindAll() ([]domain.Task, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	result := make([]domain.Task, 0, len(r.tasks))
	for _, t := range r.tasks {
		result = append(result, t)
	}
	return result, nil
}

func (r *InMemoryTaskRepo) Delete(id string) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	if _, exists := r.tasks[id]; !exists {
		return &domain.TaskNotFoundError{TaskID: id}
	}

	delete(r.tasks, id)
	return nil
}
