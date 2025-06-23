#!/bin/bash

# This script performs the daily bootstrap steps for your Nuon environment.
# It ensures commands run in sequence and stops if any command fails.

# --- Configuration ---
# Adjust this command based on your operating system and preferred terminal.
# Examples:
# For GNOME Terminal (Linux): gnome-terminal --
# For Xterm (Linux): xterm -e
# For macOS Terminal: open -a Terminal --args
# For Windows Git Bash (might require specific setup or use wsl.exe): cmd.exe /c start
NEW_TERMINAL_COMMAND="open -a Terminal --args"

# Time in seconds to wait for 'nuonctl service run-all-local' to initialize
# before running 'nuonctl seed retool' in a new terminal.
# Adjust this value if your 'run-all-local' takes more or less time to become stable.
INITIALIZATION_WAIT_TIME=15

# --- Script Start ---

# Argument parsing for wipe-db
WIPE_DB=false
for arg in "$@"; do
  if [[ "$arg" == "wipe-db" ]]; then
    WIPE_DB=true
  fi
done

echo "Starting Nuon Daily Bootstrap Script..."
echo "-------------------------------------"

# Enable strict error checking: exit immediately if a command exits with a non-zero status.
set -e

# Change to the working directory
echo ""
echo "Changing directory to ~/nuon/mono..."
cd ~/nuon/mono
echo "Current directory: $(pwd)"

# 1. Update dependencies
echo ""
echo "Step 1/5: Updating Go module dependencies..."
go mod download
echo "Go modules downloaded successfully."

# 2. Reset local generated code
echo ""
echo "Step 2/5: Resetting local generated code..."
nuonctl scripts exec reset-generated-code
echo "Local generated code reset successfully."

# 3. Refresh AWS credentials
echo ""
echo "Step 3/5: Refreshing AWS credentials (valid for 12 hours)..."
nuonctl scripts exec init-aws
echo "AWS credentials refreshed successfully."

# 3b. Ensure libpq (psql) is available
echo ""
echo "Step 3b: Ensuring 'psql' is available via Homebrew..."
brew link --overwrite --force libpq
echo "'libpq' linked. 'psql' should now be available."

# 4. Clear local database to prevent state accumulation
echo ""
echo "Step 4/5: Clearing local database..."
if [ "$WIPE_DB" = true ]; then
  # Answer 'n' to wipe the DB
  echo "Automatically answering 'n' to wipe the DB."
  echo n | nuonctl scripts exec reset-dependencies
else
  # Answer 'y' to keep the DB
  echo "Automatically answering 'y' to keep the DB."
  echo y | nuonctl scripts exec reset-dependencies
fi
echo "Local database reset successfully."

# 5. Run the stack locally
echo ""
echo "Step 5/5: Starting 'nuonctl service run-all-local' in the background..."
echo "This command will run continuously. You can stop it later by finding its process (e.g., 'pkill nuonctl')."
# Run the command in the background
nuonctl service run-all-local --skip=docs &
RUN_ALL_LOCAL_PID=$!
echo "'nuonctl service run-all-local' started with PID: $RUN_ALL_LOCAL_PID"

# Give 'run-all-local' some time to initialize
echo ""
echo "Giving 'nuonctl service run-all-local' $INITIALIZATION_WAIT_TIME seconds to initialize..."
echo "After this, 'nuonctl seed retool' will be run in a new terminal."
sleep $INITIALIZATION_WAIT_TIME

# Run 'nuonctl seed retool' in a new terminal
echo ""
echo "Attempting to open a new terminal and run 'nuonctl seed retool'..."
echo "The new terminal will automatically close after the command finishes unless an error occurs."

# Construct the command to run in the new terminal.
# The `bash -c "command; read"` part ensures the new terminal stays open
# until you press Enter, allowing you to see the output.
# For macOS, 'open -a Terminal --args' requires the command to be passed as arguments.
# We wrap the command in a single string for 'open' to execute.
NEW_TERMINAL_CMD_STRING="${NEW_TERMINAL_COMMAND} bash -c \"nuonctl seed retool; echo ''; echo '-------------------------------------'; echo 'nuonctl seed retool command finished.'; echo 'Press Enter to close this terminal...'; read -r\""

# Use eval to execute the constructed command string correctly, especially with quotes.
eval "$NEW_TERMINAL_CMD_STRING"

echo ""
echo "-------------------------------------"
echo "Nuon Daily Bootstrap Script finished."
echo "'nuonctl service run-all-local' is still running in the background of THIS terminal (PID: $RUN_ALL_LOCAL_PID)."
echo "You can close this terminal or manually stop the 'nuonctl' process when you are done."
echo "-------------------------------------"
