package main

import (
	"fmt"
	"log"
	"net/http"
	"time"

	"bookstore/controllers"
	"bookstore/models"
	"bookstore/repository"
	"bookstore/service"
)

// Simple Logging Middleware (The Security Guard at the door)
func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		next.ServeHTTP(w, r) // Let the customer into the store!

		log.Printf("📢 [%s] %s (took %v)", r.Method, r.URL.Path, time.Since(start))
	})
}

// CORS Middleware
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func main() {
	// 1. Wire up our 3 layers (Dependency Injection!)
	repo := repository.NewBookRepository()
	bookService := service.NewBookService(repo)
	bookController := controllers.NewBookController(bookService)

	// Seed 1 starter book so our store isn't empty!
	bookService.CreateBook(models.Book{
		ID:     "1",
		Title:  "The Go Programming Language",
		Author: "Alan Donovan",
		Price:  39.99,
	})

	// 2. Go 1.22 Enhanced Router!
	mux := http.NewServeMux()

	// Register our routes with HTTP methods and {id} path variables:
	mux.HandleFunc("GET /books", bookController.GetAllBooksHandler)
	mux.HandleFunc("POST /books", bookController.CreateBookHandler)
	mux.HandleFunc("GET /books/{id}", bookController.GetBookByIDHandler)
	mux.HandleFunc("DELETE /books/{id}", bookController.DeleteBookHandler)

	// 3. Chain Middlewares: Request -> Logging -> CORS -> Router
	handlerChain := loggingMiddleware(corsMiddleware(mux))

	// 4. Start the server!
	fmt.Println("==================================================")
	fmt.Println("🚀 Bookstore API Server running on http://localhost:8080")
	fmt.Println("==================================================")

	log.Fatal(http.ListenAndServe(":8080", handlerChain))
}
