package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"time"

	"taskcli/domain"
	"taskcli/repository"
)

func main() {
	repo := repository.NewInMemoryTaskRepo()

	// Seed some initial data
	repo.Save(&domain.Task{
		ID:        "1",
		Title:     "Learn Go structs and interfaces",
		Status:    domain.StatusDone,
		CreatedAt: time.Now(),
	})
	repo.Save(&domain.Task{
		ID:        "2",
		Title:     "Build full-stack hospital referral app",
		Status:    domain.StatusInProgress,
		CreatedAt: time.Now(),
	})

	reader := bufio.NewReader(os.Stdin)

	fmt.Println("==========================================")
	fmt.Println("🚀 Welcome to TaskCLI (Modular Go CLI Tool)")
	fmt.Println("==========================================")
	fmt.Println("Commands: list | add <title> | find <id> | exit")

	for {
		fmt.Print("\n> ")
		input, _ := reader.ReadString('\n')
		input = strings.TrimSpace(input)
		parts := strings.SplitN(input, " ", 2)
		cmd := parts[0]

		switch cmd {
		case "list":
			tasks, _ := repo.FindAll()
			fmt.Printf("Total Tasks: %d\n", len(tasks))
			for _, t := range tasks {
				fmt.Printf("  [%s] #%s: %s (Status: %s)\n", t.CreatedAt.Format("15:04"), t.ID, t.Title, t.Status)
			}

		case "add":
			if len(parts) < 2 || strings.TrimSpace(parts[1]) == "" {
				fmt.Println("[-] Error: please provide a title. Example: add Write tests")
				continue
			}
			newID := fmt.Sprintf("%d", time.Now().Unix()%1000)
			newTask := &domain.Task{
				ID:        newID,
				Title:     parts[1],
				Status:    domain.StatusTodo,
				CreatedAt: time.Now(),
			}
			if err := repo.Save(newTask); err != nil {
				fmt.Printf("[-] Failed to add task: %v\n", err)
			} else {
				fmt.Printf("[✓] Task added successfully! ID: %s\n", newID)
			}

		case "find":
			if len(parts) < 2 {
				fmt.Println("[-] Error: provide an ID. Example: find 1")
				continue
			}
			task, err := repo.FindByID(parts[1])
			if err != nil {
				fmt.Printf("[-] Error: %v\n", err)
			} else {
				fmt.Printf("[✓] Found: #%s %s [%s]\n", task.ID, task.Title, task.Status)
			}

		case "exit":
			fmt.Println("👋 Goodbye!")
			return

		default:
			fmt.Println("[-] Unknown command. Try: list, add <title>, find <id>, exit")
		}
	}
}
