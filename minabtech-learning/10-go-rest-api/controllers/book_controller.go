package controllers

import (
	"bookstore/models"
	"bookstore/service"
	"encoding/json"
	"net/http"
)

// BookController handles incoming web requests from the outside world
type BookController struct {
	service *service.BookService
}

// NewBookController creates a new Controller and connects it to the Manager (Service)
func NewBookController(s *service.BookService) *BookController {
	return &BookController{
		service: s,
	}
}

// GetAllBooksHandler handles GET /books
func (c *BookController) GetAllBooksHandler(w http.ResponseWriter, r *http.Request) {
	books := c.service.GetAllBooks()

	// 1. Tell the browser: "I am sending JSON back to you"
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK) // Status 200 OK

	// 2. Convert our Go slice into JSON and send it over the wire!
	json.NewEncoder(w).Encode(books)
}

// CreateBookHandler handles POST /books
func (c *BookController) CreateBookHandler(w http.ResponseWriter, r *http.Request) {
	var book models.Book

	// 1. Unpack incoming JSON from the customer's request body
	err := json.NewDecoder(r.Body).Decode(&book)
	if err != nil {
		http.Error(w, "Invalid JSON body", http.StatusBadRequest) // 400
		return
	}

	// 2. Ask the Manager (Service) to validate and create it
	createdBook, err := c.service.CreateBook(book)
	if err != nil {
		// Manager rejected it! Tell customer why:
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// 3. Success! Return 201 Created with the saved book JSON
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated) // Status 201 Created!
	json.NewEncoder(w).Encode(createdBook)
}

// GetBookByIDHandler handles GET /books/{id}
func (c *BookController) GetBookByIDHandler(w http.ResponseWriter, r *http.Request) {
	// Go 1.22 magic: grab the {id} directly from the URL!
	id := r.PathValue("id")

	book, err := c.service.GetBookByID(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound) // 404 Not Found!
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK) // 200 OK
	json.NewEncoder(w).Encode(book)
}

// DeleteBookHandler handles DELETE /books/{id}
func (c *BookController) DeleteBookHandler(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")

	err := c.service.DeleteBook(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound) // 404
		return
	}

	w.WriteHeader(http.StatusNoContent) // 204 No Content (successfully deleted!)
}
