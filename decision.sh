#!/bin/bash

# Define actions and their transition probabilities
declare -A transition_matrix
transition_matrix["A,A"]=0.5
transition_matrix["A,B"]=0.3
transition_matrix["A,C"]=0.2
transition_matrix["B,A"]=0.4
transition_matrix["B,B"]=0.4
transition_matrix["B,C"]=0.2
transition_matrix["C,A"]=0.3
transition_matrix["C,B"]=0.2
transition_matrix["C,C"]=0.5

# Function to get the next action based on current action
get_next_action() {
    local current_action=$1
    local rand_val=$((RANDOM % 100)) # Generate a random number between 0 and 99
    local cumulative_probability=0

    for action in A B C; do
        # Retrieve the transition probability
        probability=${transition_matrix["$current_action,$action"]}
        # Update cumulative probability
        cumulative_probability=$(awk "BEGIN {print $cumulative_probability + $probability * 100}")
        
        if (( $(echo "$rand_val < $cumulative_probability" | bc -l) )); then
            echo "$action"
            return
        fi
    done
}

# Initial action
current_action="A"

# Simulation loop for a predefined number of iterations
for iteration in {1..10}; do
    echo "Iteration $iteration: Current Action: $current_action"
    current_action=$(get_next_action "$current_action")
done
