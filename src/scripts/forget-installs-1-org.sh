#!/bin/bash

# Nuon Install Manager Script
# Usage: ./nuon-install-manager.sh <org_id> <api_token>
# Or set NUON_ORG_ID and NUON_API_TOKEN environment variables

set -e

# Set domain for API calls
NUON_DOMAIN="${NUON_DOMAIN:-nuon.co}"

# Prompt if using default domain
if [ -z "$NUON_DOMAIN" ] || [ "$NUON_DOMAIN" = "nuon.co" ]; then
    read -p "NUON_DOMAIN is not set. Proceed using default domain 'nuon.co'? (yes/no): " confirm_domain
    if [ "$confirm_domain" != "yes" ]; then
        echo "Operation cancelled. Set NUON_DOMAIN to your desired domain and re-run."
        exit 1
    fi
fi

# Global arrays for installs
install_ids=()
install_names=()

# Function to display usage
usage() {
    echo "Usage: $0 [org_id] [api_token]"
    echo "  org_id:    Nuon organization ID (optional - will list orgs if not provided)"
    echo "  api_token: Nuon API token (or set NUON_API_TOKEN env var)"
    echo ""
    echo "Examples:"
    echo "  $0 my-org-123 token-abc-xyz"
    echo "  $0 \"\" token-abc-xyz          # List organizations to choose from"
    echo "  NUON_API_TOKEN=token-abc-xyz $0  # List organizations using env token"
    exit 1
}

# Function to check if jq is installed
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed. Please install jq to parse JSON responses."
        echo "On macOS: brew install jq"
        echo "On Ubuntu/Debian: sudo apt-get install jq"
        echo "On CentOS/RHEL: sudo yum install jq"
        exit 1
    fi
}

# Function to list installs
list_installs() {
    local org_id="$1"
    local api_token="$2"
    
    echo "Fetching installs..."
    
    local response=$(curl -s -X 'GET' \
        "https://api.$NUON_DOMAIN/v1/installs?offset=0&limit=100&page=0" \
        -H 'accept: application/json' \
        -H "Authorization: Bearer $api_token" \
        -H "X-Nuon-Org-ID: $org_id" \
        -H 'Content-Type: application/json' \
        -d '{}' 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$response" ]; then
        echo "Error: Failed to fetch installs from API"
        exit 1
    fi
    
    # Check if response contains error
    if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
        echo "API Error: $(echo "$response" | jq -r '.error // .message // "Unknown error"')"
        exit 1
    fi
    
    # Parse and display installs
    local installs="$response"
    
    if [ "$installs" = "null" ] || [ "$installs" = "[]" ]; then
        echo "No installs found."
        return 1
    fi
    
    echo ""
    echo "Available installs:"
    echo "==================="
    
    # Clear global arrays before populating
    install_ids=()
    install_names=()
    
    local count=1
    while IFS=$'\t' read -r id name; do
        install_ids+=("$id")
        install_names+=("$name")
        echo "$count. $name (ID: $id)"
        ((count++))
    done < <(echo "$installs" | jq -r '.[] | [.id, (.name // .app_name // "Unnamed Install")] | @tsv')
    
    echo ""
    return 0
}

# Function to forget a specific install
forget_install() {
    local org_id="$1"
    local api_token="$2"
    local install_id="$3"
    local install_name="$4"
    
    echo "Forgetting install: $install_name (ID: $install_id)..."
    
    local response=$(curl -s -X 'POST' \
        "https://api.$NUON_DOMAIN/v1/installs/$install_id/forget" \
        -H 'accept: application/json' \
        -H "Authorization: Bearer $api_token" \
        -H "X-Nuon-Org-ID: $org_id" \
        -H 'Content-Type: application/json' \
        -d '{}' 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to forget install $install_name"
        return 1
    fi
    
    # Check if response contains error
    if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
        echo "API Error for $install_name: $(echo "$response" | jq -r '.error // .message // "Unknown error"')"
        return 1
    fi
    
    echo "✓ Successfully forgot install: $install_name"
    return 0
}

# Function to forget all installs
forget_all_installs() {
    local org_id="$1"
    local api_token="$2"
    
    echo ""
    echo "Forgetting all installs..."
    echo "========================="
    
    local success_count=0
    local failure_count=0
    
    for i in "${!install_ids[@]}"; do
        if forget_install "$org_id" "$api_token" "${install_ids[$i]}" "${install_names[$i]}"; then
            ((success_count++))
        else
            ((failure_count++))
        fi
        sleep 0.5  # Small delay between requests to be respectful to the API
    done
    
    echo ""
    echo "Summary:"
    echo "  Successfully forgot: $success_count installs"
    echo "  Failed to forget: $failure_count installs"
}

# Function to get and display org info
get_org_info() {
    local org_id="$1"
    local api_token="$2"
    
    local response=$(curl -s -X 'GET' \
        "https://api.$NUON_DOMAIN/v1/orgs/current" \
        -H 'accept: application/json' \
        -H "Authorization: Bearer $api_token" \
        -H "X-Nuon-Org-ID: $org_id" \
        -H 'Content-Type: application/json' 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$response" ]; then
        echo "Warning: Could not fetch organization info"
        return 1
    fi
    
    # Check if response contains error
    if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
        echo "Warning: $(echo "$response" | jq -r '.error // .message // "Could not fetch org info"')"
        return 1
    fi
    
    # Extract org info
    local org_name=$(echo "$response" | jq -r '.name // "Unknown Organization"')
    local created_at=$(echo "$response" | jq -r '.created_at // .createdAt // ""')
    
    echo "Organization: $org_name"
    echo "Organization ID: $org_id"
    
    # Format creation date in friendly format if available
    if [ -n "$created_at" ] && [ "$created_at" != "null" ] && [ "$created_at" != "" ]; then
        # Try to format the date in a friendly way
        if command -v date >/dev/null 2>&1; then
            local friendly_date
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS date command
                friendly_date=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${created_at%.*}" "+%B %d, %Y" 2>/dev/null || echo "$created_at")
            else
                # Linux date command
                friendly_date=$(date -d "$created_at" "+%B %d, %Y" 2>/dev/null || echo "$created_at")
            fi
            echo "Created: $friendly_date"
        else
            echo "Created: $created_at"
        fi
    fi
    
    echo ""
    return 0
}

# Main script logic
main() {
    # Check for jq dependency
    check_jq

    # Get org_id and api_token from arguments or environment variables
    local org_id="${1:-$NUON_ORG_ID}"
    local api_token="${2:-$NUON_API_TOKEN}"

    # Validate API token is provided
    if [ -z "$api_token" ]; then
        echo "Error: API token is required"
        echo ""
        usage
    fi

    # Validate org_id is provided
    if [ -z "$org_id" ]; then
        echo "Error: Organization ID is required. Set NUON_ORG_ID or provide as argument."
        echo ""
        usage
    fi

    echo "Nuon Install Manager"
    echo "==================="
    echo ""

    # Get and display org info for the provided org_id
    get_org_info "$org_id" "$api_token"

    # List installs
    if ! list_installs "$org_id" "$api_token"; then
        echo "No installs to manage. Exiting."
        exit 0
    fi

    # Get user choice
    echo "What would you like to do?"
    echo "  [number] - Forget a specific install (enter the number)"
    echo "  all      - Forget ALL installs"
    echo "  quit     - Exit without changes"
    echo ""
    read -p "Enter your choice: " choice
    
    case "$choice" in
        "all")
            echo ""
            read -p "Are you sure you want to forget ALL installs? This cannot be undone. (yes/no): " confirm
            if [ "$confirm" = "yes" ]; then
                forget_all_installs "$org_id" "$api_token"
            else
                echo "Operation cancelled."
            fi
            ;;
        "quit"|"q"|"exit")
            echo "Exiting without changes."
            exit 0
            ;;
        *)
            # Check if it's a valid number
            if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#install_ids[@]}" ]; then
                local index=$((choice - 1))
                local selected_id="${install_ids[$index]}"
                local selected_name="${install_names[$index]}"
                
                echo ""
                read -p "Are you sure you want to forget '$selected_name'? This cannot be undone. (yes/no): " confirm
                if [ "$confirm" = "yes" ]; then
                    forget_install "$org_id" "$api_token" "$selected_id" "$selected_name"
                else
                    echo "Operation cancelled."
                fi
            else
                echo "Invalid choice. Please enter a valid number, 'all', or 'quit'."
                exit 1
            fi
            ;;
    esac
}

# Run main function with all arguments
main "$@"