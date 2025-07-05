#!/usr/bin/env bash

# Define the namespace and app label
NAMESPACE="coder"
APP_LABEL="app.kubernetes.io/name=postgresql"
INITIAL_LOG_COUNT=40 # Number of initial log lines to show
LAST_LOG_COUNT=10    # Number of last log lines to show

# --- Find the PostgreSQL pod name ---
POSTGRES_POD_NAME=$(kubectl get pods -n "$NAMESPACE" --selector "$APP_LABEL" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POSTGRES_POD_NAME" ]; then
  echo "Error: No PostgreSQL pod found in namespace '$NAMESPACE' with label '$APP_LABEL'."
  exit 1
fi
echo "Found PostgreSQL pod: $POSTGRES_POD_NAME"

# --- Get the exact start time of the pod in RFC3339 format ---
POD_START_TIME_RFC3339=$(kubectl get pod "$POSTGRES_POD_NAME" -n "$NAMESPACE" -o jsonpath='{.status.startTime}' 2>/dev/null)

if [ -z "$POD_START_TIME_RFC3339" ]; then
  echo "Error: Could not determine start time for pod '$POSTGRES_POD_NAME'."
  exit 1
fi
echo "Pod started at: $POD_START_TIME_RFC3339"

# --- Get INITIAL logs ---
echo -e "\n--- First $INITIAL_LOG_COUNT lines of logs for $POSTGRES_POD_NAME (from startup) ---"
# Since --until-time is not supported, we fetch logs from start time
# and then pipe to head to get the *first* N lines.
# This assumes the initial startup logs appear chronologically at the beginning of the --since-time stream.
kubectl logs "$POSTGRES_POD_NAME" -n "$NAMESPACE" \
  --timestamps \
  --since-time="$POD_START_TIME_RFC3339" \
  | head -n "$INITIAL_LOG_COUNT"

# --- Get LAST logs ---
echo -e "\n--- Last $LAST_LOG_COUNT lines of current logs for $POSTGRES_POD_NAME ---"
# This remains correct as --tail works as expected.
kubectl logs "$POSTGRES_POD_NAME" -n "$NAMESPACE" --timestamps --tail="$LAST_LOG_COUNT"

echo -e "\n--- End of log output ---"