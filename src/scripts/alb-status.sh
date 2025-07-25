#!/usr/bin/env sh

# Assuming NUON_CODER_ACCESS_URL is provided by Nuon's environment
# or retrieved from a Nuon-specific output.
# Example: NUON_CODER_ACCESS_URL="https://your-subdomain.your-domain.nuon.run"

if [ -z "$NUON_CODER_ACCESS_URL" ]; then
  echo "Error: Coder external access URL not found."
  exit 1
fi

HEALTH_CHECK_URL="${NUON_CODER_ACCESS_URL}/livez"

echo "Checking Coder health at: $HEALTH_CHECK_URL"

# Use curl to get the HTTP status code.
# -s : Silent
# -o /dev/null : Discard body
# -w "%{http_code}" : Write only the HTTP status code to stdout
# --max-time 15 : Give it more time, especially for a network call
# --fail-early : Exit immediately on first transfer error
# --retry 5 --retry-delay 5 : Retry up to 5 times with 5s delay between attempts
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 --fail-early --retry 5 --retry-delay 5 "$HEALTH_CHECK_URL")

if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 307 ]; then # Include 307 if Coder still redirects
  echo "Coder health check passed! Status code: $HTTP_CODE"
  exit 0
else
  echo "Coder health check failed! Status code: $HTTP_CODE"
  exit 1
fi