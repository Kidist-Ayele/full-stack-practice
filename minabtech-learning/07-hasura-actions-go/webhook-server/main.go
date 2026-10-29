package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

// Hasura Action Payload format sent by Hasura
type ActionPayload[T any] struct {
	Action struct {
		Name string `json:"name"`
	} `json:"action"`
	Input           T                 `json:"input"`
	SessionVariables map[string]string `json:"session_variables"`
}

// 1. Login Types
type LoginInput struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginOutput struct {
	Token  string `json:"token"`
	UserID string `json:"userId"`
}

// 2. Notification Types
type NotificationInput struct {
	UserID  string `json:"userId"`
	Message string `json:"message"`
}

type NotificationOutput struct {
	Success bool `json:"success"`
}

// Login Handler
func loginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req ActionPayload[LoginInput]
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	log.Printf("[+] Hasura called Login for: %s", req.Input.Email)

	// Mock response (In a real app, check password with bcrypt and generate JWT)
	resp := LoginOutput{
		Token:  "mock-jwt-token-for-" + req.Input.Email,
		UserID: "11111111-1111-1111-1111-111111111111",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

// Send Notification Handler
func notificationHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req ActionPayload[NotificationInput]
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	log.Printf("[+] Sending notification to user %s: '%s'", req.Input.UserID, req.Input.Message)

	resp := NotificationOutput{
		Success: true,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func main() {
	http.HandleFunc("/login", loginHandler)
	http.HandleFunc("/sendNotification", notificationHandler)

	fmt.Println("🚀 Go Webhook Server running on http://0.0.0.0:3000")
	log.Fatal(http.ListenAndServe(":3000", nil))
}
