package main

import (
	"context"
	"fmt"
	"math/rand"
	"sync"
	"time"
)

// 1. Job represents a unit of work (e.g. processing a hospital patient record)
type Job struct {
	ID       int
	Data     string
	Duration time.Duration // Simulated work time
}

// 2. Result represents the outcome of the job
type Result struct {
	JobID  int
	Output string
	Err    error
}

// 3. Worker function: One worker taking jobs from the conveyor belt
func worker(ctx context.Context, id int, jobs <-chan Job, results chan<- Result, wg *sync.WaitGroup) {
	defer wg.Done() // Tell the teacher (WaitGroup) this worker has left when finished

	for {
		select {
		// Case A: The manager sounded the alarm (Timeout or Cancel)
		case <-ctx.Done():
			fmt.Printf("⚠️ Worker %d received cancellation signal: %v. Stopping!\n", id, ctx.Err())
			return

		// Case B: A job arrived on the conveyor belt
		case job, ok := <-jobs:
			if !ok {
				// The conveyor belt was closed (no more jobs)
				return
			}

			fmt.Printf("👷 Worker %d started job #%d (%s)...\n", id, job.ID, job.Data)

			// Simulate work that checks for cancellation
			select {
			case <-time.After(job.Duration):
				// Finished work successfully!
				res := Result{
					JobID:  job.ID,
					Output: fmt.Sprintf("Job #%d processed successfully by Worker %d", job.ID, id),
				}
				results <- res
				fmt.Printf("✅ Worker %d finished job #%d!\n", id, job.ID)

			case <-ctx.Done():
				// Cancelled in the middle of working on a job!
				fmt.Printf("🛑 Worker %d interrupted while working on job #%d!\n", id, job.ID)
				return
			}
		}
	}
}

func main() {
	fmt.Println("==================================================")
	fmt.Println("🚀 Go Concurrent Worker Pool with Context Timeout")
	fmt.Println("==================================================")

	const numWorkers = 3
	const numJobs = 8

	// Channels: The conveyor belts
	jobs := make(chan Job, numJobs)
	results := make(chan Result, numJobs)

	// Context with 2-second timeout (Safety alarm!)
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	var wg sync.WaitGroup

	// Step A: Spawn the 3 workers
	for w := 1; w <= numWorkers; w++ {
		wg.Add(1)
		go worker(ctx, w, jobs, results, &wg)
	}

	// Step B: Send 8 jobs into the conveyor belt
	for j := 1; j <= numJobs; j++ {
		// Random work duration between 300ms and 1200ms
		simulatedDuration := time.Duration(300+rand.Intn(900)) * time.Millisecond
		jobs <- Job{
			ID:       j,
			Data:     fmt.Sprintf("Patient-Report-%d", j),
			Duration: simulatedDuration,
		}
	}
	close(jobs) // Close the conveyor belt: no more new jobs will be added

	// Step C: Wait for all workers to finish in the background, then close results
	go func() {
		wg.Wait()
		close(results)
	}()

	// Step D: Collect results as they arrive
	successCount := 0
	for res := range results {
		successCount++
		fmt.Printf("📥 Result Received: %s\n", res.Output)
	}

	fmt.Println("--------------------------------------------------")
	if ctx.Err() == context.DeadlineExceeded {
		fmt.Println("⏱️ STATUS: Context deadline timed out! Remaining jobs were cancelled gracefully.")
	} else {
		fmt.Println("🎉 STATUS: All jobs finished before timeout!")
	}
	fmt.Printf("📊 Summary: %d / %d jobs completed.\n", successCount, numJobs)
}
