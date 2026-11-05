package service

import (
	"bookstore/models"
	"bookstore/repository"
	"errors"
)

// BookService is the Manager / Brain of our bookstore
type BookService struct {
	repo *repository.BookRepository
}

// NewBookService creates a new Manager and gives them a Storage Keeper
func NewBookService(repo *repository.BookRepository) *BookService {
	return &BookService{
		repo: repo,
	}
}

// CreateBook validates the book before telling the repository to save it
func (s *BookService) CreateBook(book models.Book) (models.Book, error) {
	if book.Title == "" {
		return models.Book{}, errors.New("book title cannot be empty")
	}
	if book.Author == "" {
		return models.Book{}, errors.New("book author cannot be empty")
	}
	if book.Price <= 0 {
		return models.Book{}, errors.New("book price must be greater than zero")
	}

	// All checks passed! Tell the repository to save it to the shelf:
	savedBook := s.repo.Save(book)
	return savedBook, nil
}

// GetAllBooks asks the repository for all books
func (s *BookService) GetAllBooks() []models.Book {
	return s.repo.FindAll()
}

// GetBookByID asks the repository for one book by ID
func (s *BookService) GetBookByID(id string) (models.Book, error) {
	return s.repo.FindByID(id)
}

// DeleteBook asks the repository to remove a book by ID
func (s *BookService) DeleteBook(id string) error {
	return s.repo.Delete(id)
}
