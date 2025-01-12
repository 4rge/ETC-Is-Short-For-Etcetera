#!/bin/bash

# Define actions and their transition probabilities based on last two actions
declare -A transition_matrix
# Transition probabilities based on emotional states and previous actions
# Aggressive, Chill, Balanced matrices as examples for each pair of last actions
# Action transitions for Aggressive (A):
transition_matrix["aggressive,A,A,A"]=0.5
transition_matrix["aggressive,A,A,B"]=0.3
transition_matrix["aggressive,A,A,C"]=0.2
transition_matrix["aggressive,A,B,A"]=0.4
transition_matrix["aggressive,A,B,B"]=0.4
transition_matrix["aggressive,A,B,C"]=0.2
transition_matrix["aggressive,A,C,A"]=0.3
transition_matrix["aggressive,A,C,B"]=0.2
transition_matrix["aggressive,A,C,C"]=0.5
transition_matrix["aggressive,B,A,A"]=0.4
transition_matrix["aggressive,B,A,B"]=0.4
transition_matrix["aggressive,B,A,C"]=0.2
transition_matrix["aggressive,B,B,A"]=0.3
transition_matrix["aggressive,B,B,B"]=0.5
transition_matrix["aggressive,B,B,C"]=0.2
transition_matrix["aggressive,B,C,A"]=0.2
transition_matrix["aggressive,B,C,B"]=0.5
transition_matrix["aggressive,B,C,C"]=0.3
transition_matrix["aggressive,C,A,A"]=0.3
transition_matrix["aggressive,C,A,B"]=0.2
transition_matrix["aggressive,C,A,C"]=0.5
transition_matrix["aggressive,C,B,A"]=0.4
transition_matrix["aggressive,C,B,B"]=0.2
transition_matrix["aggressive,C,B,C"]=0.4
transition_matrix["aggressive,C,C,A"]=0.5
transition_matrix["aggressive,C,C,B"]=0.3
transition_matrix["aggressive,C,C,C"]=0.2

# Chill
transition_matrix["chill,A,A,A"]=0.3
transition_matrix["chill,A,A,B"]=0.4
transition_matrix["chill,A,A,C"]=0.3
transition_matrix["chill,A,B,A"]=0.3
transition_matrix["chill,A,B,B"]=0.4
transition_matrix["chill,A,B,C"]=0.3
transition_matrix["chill,A,C,A"]=0.4
transition_matrix["chill,A,C,B"]=0.3
transition_matrix["chill,A,C,C"]=0.3
transition_matrix["chill,B,A,A"]=0.4
transition_matrix["chill,B,A,B"]=0.3
transition_matrix["chill,B,A,C"]=0.3
transition_matrix["chill,B,B,A"]=0.2
transition_matrix["chill,B,B,B"]=0.5
transition_matrix["chill,B,B,C"]=0.3
transition_matrix["chill,B,C,A"]=0.3
transition_matrix["chill,B,C,B"]=0.4
transition_matrix["chill,B,C,C"]=0.3
transition_matrix["chill,C,A,A"]=0.4
transition_matrix["chill,C,A,B"]=0.3
transition_matrix["chill,C,A,C"]=0.3
transition_matrix["chill,C,B,A"]=0.3
transition_matrix["chill,C,B,B"]=0.3
transition_matrix["chill,C,B,C"]=0.4
transition_matrix["chill,C,C,A"]=0.4
transition_matrix["chill,C,C,B"]=0.3
transition_matrix["chill,C,C,C"]=0.3

# Balanced
transition_matrix["balanced,A,A,A"]=0.4
transition_matrix["balanced,A,A,B"]=0.4
transition_matrix["balanced,A,A,C"]=0.2
transition_matrix["balanced,A,B,A"]=0.4
transition_matrix["balanced,A,B,B"]=0.4
transition_matrix["balanced,A,B,C"]=0.2
transition_matrix["balanced,A,C,A"]=0.3
transition_matrix["balanced,A,C,B"]=0.2
transition_matrix["balanced,A,C,C"]=0.5
transition_matrix["balanced,B,A,A"]=0.4
transition_matrix["balanced,B,A,B"]=0.4
transition_matrix["balanced,B,A,C"]=0.2
transition_matrix["balanced,B,B,A"]=0.3
transition_matrix["balanced,B,B,B"]=0.5
transition_matrix["balanced,B,B,C"]=0.2
transition_matrix["balanced,B,C,A"]=0.2
transition_matrix["balanced,B,C,B"]=0.5
transition_matrix["balanced,B,C,C"]=0.3
transition_matrix["balanced,C,A,A"]=0.3
transition_matrix["balanced,C,A,B"]=0.2
transition_matrix["balanced,C,A,C"]=0.5
transition_matrix["balanced,C,B,A"]=0.4
transition_matrix["balanced,C,B,B"]=0.2
transition_matrix["balanced,C,B,C"]=0.4
transition_matrix["balanced,C,C,A"]=0.5
transition_matrix["balanced,C,C,B"]=0.3
transition_matrix["balanced,C,C,C"]=0.2


# Function to get the next action based on last two actions and current emotion
get_next_action() {
    local last_action1=$1
    local last_action2=$2
    local current_emotion=$3
    local rand_val=$((RANDOM % 100)) # Generate a random number between 0 and 99
    local cumulative_probability=0
    local action

    # Check transition probabilities based on the last two actions and current emotion
    for action in A B C; do
        # Retrieve the transition probability based on emotion
        probability=${transition_matrix["$current_emotion,$last_action1,$last_action2,$action"]}
        # Update cumulative probability
        cumulative_probability=$(awk "BEGIN {print $cumulative_probability + $probability * 100}")

        # Decision based on random value
        if (( $(echo "$rand_val < $cumulative_probability" | bc -l) )); then
            echo "$action"
            return
        fi
    done
}

# Initial actions and state
last_action1="B" # Previous action 1
last_action2="B" # Previous action 2
current_emotion="balanced"  # Initialize emotional state

# Variables for calculation of statistics
declare -a action_history
declare -a success_actions # Keep track of successful actions
sum=0
count=0
declare -i points=10 # Start with some points/currency

# Simulation loop for a predefined number of iterations
for iteration in {1..10}; do
    current_action=$(get_next_action "$last_action1" "$last_action2" "$current_emotion")
    
    # Success condition (example assumption for successful actions)
    success_condition() {
        [[ $1 == "A" || $1 == "C" ]]  # Assume A and C are successful actions
    }

    if success_condition "$current_action"; then
        success_actions+=("$current_action")
        points=$((points + 1))  # Increase points on success
    else
        points=$((points - 1))  # Decrease points on failure
    fi

    # Cognitive Bias Implementation (boost likelihood for successful actions)
    for action in "${success_actions[@]}"; do
        if [[ $current_action == $action ]]; then
            current_emotion="aggressive" # More likely to be aggressive after success
        fi
    done

    # Decay of Memory (remove oldest action from success actions)
    if [[ ${#success_actions[@]} -gt 5 ]]; then
        unset success_actions[0]  # Remove oldest action to simulate decay
    fi

    # Temporal Effects: Change probabilities over time
    if (( iteration > 5 )); then
        # Increase the aggression if points are low
        [[ $points -lt 5 ]] && current_emotion="aggressive"
    fi
    
    # Track each action in history
    action_history+=("$current_action")
    
    # Update the last actions
    last_action1=$last_action2
    last_action2=$current_action
done

# Calculate statistics
sum=0
count=0
for action in "${action_history[@]}"; do
    value=0; [[ $action == "B" ]] && value=1; [[ $action == "C" ]] && value=2
    sum=$((sum + value))
    count=$((count + 1))
done

mean=$(echo "scale=2; $sum / $count" | bc)

declare -A frequency
for action in "${action_history[@]}"; do
    ((frequency[$action]++))
done

mode="A"
max_frequency=0
for action in "${!frequency[@]}"; do
    (( frequency[$action] > max_frequency )) && { max_frequency=${frequency[$action]}; mode=$action; }
done

# Calculate median
sorted_history=($(for x in "${action_history[@]}"; do echo "$x"; done | sort))
(( count % 2 == 1 )) && median="${sorted_history[$((count / 2))]}" || {
    mid1="${sorted_history[$((count / 2))]}"
    mid2="${sorted_history[$((count / 2 - 1))]}"
    median=$mid1
}

# Prepare final output
final_result="Final Actions History: ${action_history[@]}"
final_stats="Mean (numeric context): $mean | Median: $median | Mode: $mode | Final Points: $points"

# Display results
echo "$final_result"
echo "$final_stats"
