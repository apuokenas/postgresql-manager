#!/bin/bash

# PostgreSQL Status Check Script for macOS
# 
# Author: Apuokėnas
# Version: v1.0
# Last changed: 2025-03-31
#
# Purpose: Checks if the PostgreSQL 17 server is currently running
#
# How it works:
# - Uses AppleScript to open a Terminal window
# - Uses pg_ctl with status command to query the server state
# - Interprets exit code to display a user-friendly message
#
# Exit codes:
# - 0: server is running
# - 3: server is not running
# - 4: data directory issues

# Define PostgreSQL version and paths
PG_VERSION="17"
PG_BINDIR="/usr/local/opt/postgresql@${PG_VERSION}/bin"
PG_DATADIR="/usr/local/var/postgresql@${PG_VERSION}"

# Function to handle errors
handle_error() {
  osascript << EOF
tell application "Terminal"
  do script "clear; echo \"Error: $1\"; echo \"\"; echo \"Press Return to close this window.\"; read -r; osascript -e 'tell application \\\"Terminal\\\" to close (every window whose frontmost is true)'"
  activate
end tell
EOF
  exit 1
}

# Validate prerequisites
if [ ! -d "$PG_BINDIR" ]; then
  handle_error "PostgreSQL binaries not found at ${PG_BINDIR}"
fi

if [ ! -d "$PG_DATADIR" ]; then
  handle_error "PostgreSQL data directory not found at ${PG_DATADIR}"
fi

if [ ! -x "${PG_BINDIR}/pg_ctl" ]; then
  handle_error "PostgreSQL control utility not executable"
fi

# Check PostgreSQL status and store results
STATUS=$(PGDATA="$PG_DATADIR" "${PG_BINDIR}/pg_ctl" status 2>&1)
EXIT_CODE=$?

# Create temporary script with unique name in a persistent location
TMP_DIR="${HOME}/.postgres_scripts"
mkdir -p "$TMP_DIR"
TMP_SCRIPT="${TMP_DIR}/pg_status_$$_$(date +%s).sh"

# Encode status to avoid issues with special characters
ENCODED_STATUS=$(echo "$STATUS" | base64)

# Write script content
cat > "$TMP_SCRIPT" << 'INNERSCRIPT'
#!/bin/bash
clear
ENCODED_STATUS="$1"
EXIT_CODE=$2

# Decode the status
POSTGRES_STATUS=$(echo "$ENCODED_STATUS" | base64 --decode 2>/dev/null)

echo "$POSTGRES_STATUS"
echo

if [ $EXIT_CODE -eq 0 ]; then
  echo "PostgreSQL is currently running"
elif [ $EXIT_CODE -eq 3 ]; then
  echo "PostgreSQL is not running"
elif [ $EXIT_CODE -eq 4 ]; then
  echo "PostgreSQL data directory issue detected"
else
  echo "Unknown PostgreSQL status (exit code: $EXIT_CODE)"
fi

echo
echo "Press Return to close this window."
read -r

# Self-cleanup when done
rm -f "$0"

# Use AppleScript to close the Terminal window
osascript -e 'tell application "Terminal" to close (every window whose frontmost is true)'
INNERSCRIPT

# Make it executable
chmod +x "$TMP_SCRIPT"

# Open Terminal and run the script with arguments
osascript << EOF
tell application "Terminal"
    do script "\"$TMP_SCRIPT\" \"$ENCODED_STATUS\" $EXIT_CODE"
    activate
end tell
EOF
