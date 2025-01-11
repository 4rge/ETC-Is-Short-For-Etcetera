#!/bin/bash

# Cite: Durrett, R. (2010). Probability: Theory and Examples. Cambridge University Press.
# Define actions and their transition probabilities based on last two actions
declare -A transition_matrix
transition_matrix["A,A,A"]=0.5
transition_matrix["A,A,B"]=0.3
transition_matrix["A,A,C"]=0.2
transition_matrix["A,B,A"]=0.4
transition_matrix["A,B,B"]=0.4
transition_matrix["A,B,C"]=0.2
transition_matrix["A,C,A"]=0.3
transition_matrix["A,C,B"]=0.2
transition_matrix["A,C,C"]=0.5
transition_matrix["B,A,A"]=0.4
transition_matrix["B,A,B"]=0.4
transition_matrix["B,A,C"]=0.2
transition_matrix["B,B,A"]=0.3
transition_matrix["B,B,B"]=0.5
transition_matrix["B,B,C"]=0.2
transition_matrix["B,C,A"]=0.2
transition_matrix["B,C,B"]=0.5
transition_matrix["B,C,C"]=0.3
transition_matrix["C,A,A"]=0.3
transition_matrix["C,A,B"]=0.2
transition_matrix["C,A,C"]=0.5
transition_matrix["C,B,A"]=0.4
transition_matrix["C,B,B"]=0.2
transition_matrix["C,B,C"]=0.4
transition_matrix["C,C,A"]=0.5
transition_matrix["C,C,B"]=0.3
transition_matrix["C,C,C"]=0.2

# Cite: Feller, W. (1968). An Introduction to Probability Theory and Its Applications, Volume 1. Wiley.
# Function to get the next action based on last two actions
get_next_action() {
    local last_action1=$1
    local last_action2=$2
    local rand_val=$((RANDOM % 100)) # Generate a random number between 0 and 99 Cite: Knuth, D. E. (1998). The Art of Computer Programming, Volume 2: Seminumerical Algorithms. Addison-Wesley.
    local cumulative_probability=0
    local action

    # Check transition probabilities based on the last two actions
    for action in A B C; do
        # Retrieve the transition probability
        probability=${transition_matrix["$last_action1,$last_action2,$action"]}
        # Update cumulative probability
        cumulative_probability=$(awk "BEGIN {print $cumulative_probability + $probability * 100}")
        
        if (( $(echo "$rand_val < $cumulative_probability" | bc -l) )); then
            echo "$action"
            return
        fi
    done
}

# Cite: Schacter, D. L. (1996). The seven sins of memory: Insights from psychology and cognitive neuroscience. American Psychologist, 51(10), 182-198. This paper delves into how memory (including episodic memory) affects decision-making.
# Initial actions
last_action1="A" # Previous action 1
last_action2="A" # Previous action 2

# Variables for calculation of statistics
declare -a action_history
action_mapping=(A B C)  # Mapping of actions to numeric values
sum=0
count=0

# Cite: Breiman, L. (1992). Probability. SIAM.
# Simulation loop for a predefined number of iterations
for iteration in {1..10}; do
    current_action=$(get_next_action "$last_action1" "$last_action2")
    
    # Track each action in history
    action_history+=("$current_action")
    
    # Update the last actions
    last_action1=$last_action2
    last_action2=$current_action
done

# Triola, M. F. (2018). Elementary Statistics. Pearson Education.
# Calculate statistics
for action in "${action_history[@]}"; do
    if [[ $action == "A" ]]; then
        value=0
    elif [[ $action == "B" ]]; then
        value=1
    else
        value=2
    fi
    
    sum=$((sum + value))
    count=$((count + 1))
done

# Calculate mean
mean=$(echo "scale=2; $sum / $count" | bc)

# Calculate mode
declare -A frequency
for action in "${action_history[@]}"; do
    ((frequency[$action]++))
done

mode="A"
max_frequency=0
for action in "${!frequency[@]}"; do
    if (( frequency[$action] > max_frequency )); then
        max_frequency=${frequency[$action]}
        mode=$action
    fi
done

# Calculate median
sorted_history=($(for x in "${action_history[@]}"; do echo "$x"; done | sort))
if (( count % 2 == 1 )); then
    median="${sorted_history[$((count / 2))]}"
else
    mid1="${sorted_history[$((count / 2))]}"
    mid2="${sorted_history[$((count / 2 - 1))]}"
    # In a real numeric context you'd average the two, but as they are categories, use one as representative
    median=$mid1
fi

# Prepare final output
final_result="Final Actions History: ${action_history[@]}"
final_stats="Mean (numeric context): $mean | Median: $median | Mode: $mode"

# Display results
echo "$final_result"
echo "$final_stats"
