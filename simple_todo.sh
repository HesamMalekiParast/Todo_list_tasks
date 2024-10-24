#!/bin/bash

TODO_FILE="incomplete_tasks.txt"
COMPLETED_FILE="completed_tasks.txt"
DELETED_FILE="deleted_tasks.txt"

# Function to display usage information
usage() {
    echo "Usage: $0 [add|view|complete|delete|exit]"
    echo "  add [task description] [priority]: Add a new task with optional priority (1-3)."
    echo "  view: Display incomplete tasks."
    echo "  complete [task description]: Mark a task as complete."
    echo "  delete [task description]: Remove a task and add it to the deleted tasks list."
    echo "  exit: Exit the program."
    exit 1
}

# Ensure the necessary files exist
create_files() {
    touch "$TODO_FILE" "$COMPLETED_FILE" "$DELETED_FILE"
}

# Function to add a new task
add_task() {
    local task=$1
    local priority=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    if [ -z "$task" ]; then
        echo "Error: No task description provided."
        exit 1
    fi

    if [[ ! -z "$priority" && ( "$priority" -lt 1 || "$priority" -gt 3 ) ]]; then
        echo "Error: Priority must be between 1 and 3."
        exit 1
    fi

    if [ -z "$priority" ]; then
        echo "$timestamp - $task" >> "$TODO_FILE"
    else
        echo "$timestamp - [Priority: $priority] $task" >> "$TODO_FILE"
    fi
    echo "Task added: $task"
}

# Function to display incomplete tasks
view_tasks() {
    echo -e "\nIncomplete Tasks:"
    if [ -s "$TODO_FILE" ]; then
        nl -w 2 -s '. ' "$TODO_FILE"
    else
        echo "No incomplete tasks found."
    fi
}

# Function to mark a task as complete
complete_task() {
    local task_desc="$1"
    if [ -z "$task_desc" ]; then
        echo "Error: Task description is required."
        exit 1
    fi

    task=$(grep -F "$task_desc" "$TODO_FILE")
    if [ -n "$task" ]; then
        echo "$task" >> "$COMPLETED_FILE"
        sed -i.bak "/$task_desc/d" "$TODO_FILE"
        echo "Task marked as complete: $task"
    else
        echo "Error: Task does not exist."
    fi
}

# Function to delete a specified task
delete_task() {
    local task_desc="$1"
    if [ -z "$task_desc" ]; then
        echo "Error: Task description is required."
        exit 1
    fi

    task=$(grep -F "$task_desc" "$TODO_FILE")
    if [ -n "$task" ]; then
        echo "$task" >> "$DELETED_FILE"
        sed -i.bak "/$task_desc/d" "$TODO_FILE"
        echo "Task deleted: $task"
    else
        echo "Error: Task does not exist."
    fi
}


# Main script execution
create_files
if [ $# -lt 1 ]; then
    usage
fi

case $1 in
    add)
        shift
        add_task "$@"
        ;;
    view)
        view_tasks
        ;;
    complete)
        complete_task "$2"
        ;;
    delete)
        delete_task "$2"
        ;;
    viewcompleted)
        view_completed_tasks
        ;;
    exit)
        echo "Exiting the program."
        exit 0
        ;;
    *)
        usage
        ;;
esac
