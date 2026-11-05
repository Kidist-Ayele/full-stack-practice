package repository

import (
	"bookstore/models"
	"errors"
	"sync"
)

// BookRepository is our Storage Keeper
type BookRepository struct {
	mu    sync.RWMutex
	books map[string]models.Book
}

// BookRepository is our Storage Keeper
func NewBookRepository() *BookRepository {
	return &BookRepository{
		books: make(map[string]models.Book),
	}
}

// 1. Save adds or updates a book on our shelf
func (r *BookRepository) Save(book models.Book) models.Book {
	r.mu.Lock()
	defer r.mu.Unlock()

	r.books[book.ID] = book
	return book
}

// 2. FindAll returns every book on our shelf
func (r *BookRepository) FindAll() []models.Book {
	r.mu.RLock()
	defer r.mu.RUnlock()

	list := make([]models.Book, 0, len(r.books))
	for _, b := range r.books {
		list = append(list, b)
	}
	return list
}

// 3. FindByID looks for one specific book by ID
func (r *BookRepository) FindByID(id string) (models.Book, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	book, exists := r.books[id]
	if !exists {
		return models.Book{}, errors.New("book not found")
	}
	return book, nil
}

// 4. Delete removes a book from our shelf by ID
func (r *BookRepository) Delete(id string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	_, exists := r.books[id]
	if !exists {
		return errors.New("book not found")
	}
	delete(r.books, id)
	return nil
}
