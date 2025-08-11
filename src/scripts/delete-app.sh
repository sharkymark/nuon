#!/bin/bash

# Ensure script exits on first error
set -e
set -o pipefail # Crucial: ensures pipe failures are caught

# This script automates the deletion of all components for a Nuon app(s).
# It takes an app name or "*" to delete all apps as an argument.
# It prevents app deletion if there are existing installs.
# Crucially, it will NOT attempt to delete an app if component deletion truly fails (verified by re-listing with JSON and wc -l).

TARGET_APP_NAME="$1"

# Check if an argument was provided
if [ -z "$TARGET_APP_NAME" ]; then
  echo "Error: Please provide the Nuon app name or '*' as an argument."
  echo "Usage: $0 <app_name> | *"
  exit 1
fi

# Wait time (in seconds) after deleting a component before verifying deletion
COMPONENT_DELETE_WAIT_SECONDS=20 # Change this value to adjust the wait time

## Function to delete components and optionally the app
delete_app_and_components() {
  # Trim initial input app name
  local APP_NAME_TO_DELETE_RAW="$1"
  local APP_NAME_TO_DELETE=$(echo "$APP_NAME_TO_DELETE_RAW" | xargs) # Trim leading/trailing whitespace

  local components_failed_to_delete=false # Flag to track if ANY component deletion truly failed

  echo "----------------------------------------------------"
  echo "Processing app: $APP_NAME_TO_DELETE"
  echo "----------------------------------------------------"

  # --- Retrieve App ID (still needed for install check and final app delete) ---
  echo "Retrieving App ID for '$APP_NAME_TO_DELETE' (needed for install check and final app delete)..."
  APP_ID=$(nuon apps list --json | jq -r ".[] | select(.name == \"$APP_NAME_TO_DELETE\") | .id")

  if [ -z "$APP_ID" ]; then
    echo "Error: App '$APP_NAME_TO_DELETE' not found. Skipping deletion."
    return 1 # Indicate failure
  else
    echo "Found App ID: $APP_ID for App Name: $APP_NAME_TO_DELETE"
  fi

  ## Check for existing installs
  echo "Checking for existing installs for app: $APP_ID ($APP_NAME_TO_DELETE)..."
  INSTALL_COUNT=$(nuon installs list --json | jq -r ".[] | select(.app_id == \"$APP_ID\")" | wc -l)

  if [ "$INSTALL_COUNT" -gt 0 ]; then
    echo "Error: Found $INSTALL_COUNT existing install(s) for app '$APP_NAME_TO_DELETE' (ID: $APP_ID)."
    echo "Skipping deletion for this app. Please delete all existing installs before attempting to delete the app."
    echo "You can list installs with: nuon installs list"
    return 1 # Indicate failure to delete this app
  else
    echo "No existing installs found for app '$APP_NAME_TO_DELETE' (ID: $APP_ID). Proceeding with component deletion."
  fi

  echo "----------------------------------------------------"

  ## Get and delete components
  while true; do
    echo "Listing components for app: $APP_NAME_TO_DELETE..."
    COMPONENT_LIST_JSON=$(nuon components list -a "$APP_NAME_TO_DELETE" --json)
    COMPONENT_COUNT=$(echo "$COMPONENT_LIST_JSON" | jq 'length')
    if [ -z "$COMPONENT_LIST_JSON" ] || [ "$COMPONENT_COUNT" -eq 0 ]; then
      echo "No components found for app '$APP_NAME_TO_DELETE'."
      break
    fi
    echo "Found components for app '$APP_NAME_TO_DELETE':"
    for ((i=0; i<COMPONENT_COUNT; i++)); do
      NAME=$(echo "$COMPONENT_LIST_JSON" | jq -r ".[$i].name")
      ID=$(echo "$COMPONENT_LIST_JSON" | jq -r ".[$i].id")
      echo "  [$((i+1))] Name: $NAME | ID: $ID"
    done
    echo
    read -p "Enter the numbers of the components you want to delete (comma-separated, or 'all' to delete all, or press Enter to skip): " COMPONENT_SELECTION
    if [[ -z "$COMPONENT_SELECTION" ]]; then
      echo "No components selected. Skipping deletion for app '$APP_NAME_TO_DELETE'."
      break
    fi
    if [[ "$COMPONENT_SELECTION" =~ ^[Aa][Ll][Ll]$ ]]; then
      SELECTED_INDICES=$(seq 1 $COMPONENT_COUNT)
    else
      SELECTED_INDICES=$(echo "$COMPONENT_SELECTION" | tr ',' ' ')
    fi
    echo "You selected: $SELECTED_INDICES"
    read -p "Are you sure you want to delete these components? (y/N): " CONFIRM_DELETE
    if [[ ! "$CONFIRM_DELETE" =~ ^[Yy]$ ]]; then
      echo "Skipping deletion for app '$APP_NAME_TO_DELETE' as per user request."
      break
    fi
    local temp_deletion_status="SUCCESS"
    for idx in $SELECTED_INDICES; do
      i=$((idx-1))
      COMPONENT_ID=$(echo "$COMPONENT_LIST_JSON" | jq -r ".[$i].id" | xargs)
      COMPONENT_NAME=$(echo "$COMPONENT_LIST_JSON" | jq -r ".[$i].name" | xargs)
      echo "---"
      echo "Processing component: Name='$COMPONENT_NAME', ID='$COMPONENT_ID'"
      echo "Attempting to delete component: $COMPONENT_ID for app '$APP_NAME_TO_DELETE'..."
      DELETE_OUTPUT=$(nuon components delete -a "$APP_NAME_TO_DELETE" -c "$COMPONENT_ID" 2>&1)
      echo "$DELETE_OUTPUT"
      # Check for dependency error
      if echo "$DELETE_OUTPUT" | grep -q "components dependents exist"; then
        DEPENDENT_IDS=$(echo "$DELETE_OUTPUT" | grep -oE 'Dependent IDs: \[[^]]*\]' | sed 's/Dependent IDs: \[//;s/\]//')
        echo "❌ ERROR: Component $COMPONENT_ID could not be deleted due to dependencies. Dependent IDs: [$DEPENDENT_IDS]"
        temp_deletion_status="FAILURE"
        continue
      fi
      sleep $COMPONENT_DELETE_WAIT_SECONDS
      VERIFY_COUNT=$(nuon components list -a "$APP_NAME_TO_DELETE" --json | jq -r ".[] | select(.id == \"$COMPONENT_ID\")" | wc -l)
      if [ "$VERIFY_COUNT" -eq 0 ]; then
        echo "✅ SUCCESS: Component $COMPONENT_ID is no longer listed, confirming deletion."
      else
        echo "❌ ERROR: Component $COMPONENT_ID FAILED to delete (still present after attempt)."
        temp_deletion_status="FAILURE"
      fi
    done
    if [ "$temp_deletion_status" == "FAILURE" ]; then
      components_failed_to_delete=true
    fi
    echo "Component deletion round completed."
  done

  echo "----------------------------------------------------"

  ## Decide whether to delete the app itself
  if $components_failed_to_delete; then
    echo "🚫 SKIPPING APP DELETION for '$APP_NAME_TO_DELETE' (ID: $APP_ID) because one or more components truly failed to delete. 🚫"
    return 1 # Indicate overall failure for this app, preventing further action if this was part of a loop
  else
    echo "All components successfully deleted or no components found. Proceeding with app deletion."
    echo "Deleting app: $APP_NAME_TO_DELETE (ID: $APP_ID)..."
    DELETE_APP_OUTPUT=$(nuon apps delete -a "$APP_ID" --confirm 2>&1)
    echo "$DELETE_APP_OUTPUT" # Print the full output from Nuon CLI

    # We still use output parsing for app deletion, as it's the final step
    if echo "$DELETE_APP_OUTPUT" | grep -q "SUCCESS.*successfully queued app to be deleted"; then
      echo "✅ SUCCESS: Successfully queued app '$APP_NAME_TO_DELETE' (ID: $APP_ID) for deletion. ✅"
      return 0 # Indicate success
    else
      echo "❌ ERROR: Failed to delete app '$APP_NAME_TO_DELETE' (ID: $APP_ID) based on output analysis. ❌"
      return 1 # Indicate failure
    fi
  fi
}

# Main logic based on the argument
if [ "$TARGET_APP_NAME" == "*" ]; then
  echo "----------------------------------------------------"
  echo "Attempting to delete ALL Nuon apps and their components (if no installs present)."
  echo "--------------------------------------------------------------------------------"

  APP_LIST_JSON=$(nuon apps list --json)

  if [ -z "$APP_LIST_JSON" ] || [ "$(echo "$APP_LIST_JSON" | jq 'length')" -eq 0 ]; then
    echo "No Nuon apps found to delete."
  else
    APP_NAMES=$(echo "$APP_LIST_JSON" | jq -r '.[].name' | xargs -n1) # Trim and ensure one name per line

    for APP_NAME_ITER in $APP_NAMES; do # Iterate over clean app names
      delete_app_and_components "$APP_NAME_ITER"
    done
  fi
else
  # Single app deletion
  delete_app_and_components "$TARGET_APP_NAME"
fi

echo "----------------------------------------------------"
echo "Script finished."