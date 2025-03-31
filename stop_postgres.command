#!/bin/bash

# PostgreSQL Stop Script for macOS
# 
# Author: Apuokėnas
# Version: v1.0
# Last changed: 2025-03-31
#
# Purpose: Stops the running PostgreSQL 17 server
#
# How it works:
# - Uses AppleScript to open a Terminal window
# - Uses pg_ctl to send a shutdown signal to PostgreSQL
# - Displays status messages based on success/failure
#
# Note: This script will only work if there's a PostgreSQL instance
#       running with the specified data directory.

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

# Check if PostgreSQL is actually running before attempting to stop
if ! "${PG_BINDIR}/pg_ctl" -D "$PG_DATADIR" status &>/dev/null; then
  handle_error "PostgreSQL is not currently running"
fi

# Stop PostgreSQL and capture the result
STOP_OUTPUT=$("${PG_BINDIR}/pg_ctl" -D "$PG_DATADIR" stop 2>&1)
EXIT_CODE=$?

# Create temporary script with unique name in a persistent location
TMP_DIR="${HOME}/.postgres_scripts"
mkdir -p "$TMP_DIR"
TMP_SCRIPT="${TMP_DIR}/pg_stop_$$_$(date +%s).sh"

# Encode output to avoid issues with quotes and newlines
ENCODED_OUTPUT=$(echo "$STOP_OUTPUT" | base64)

# Write script content
cat > "$TMP_SCRIPT" << 'INNERSCRIPT'
#!/bin/bash
clear
ENCODED_OUTPUT="$1"
EXIT_CODE=$2

# Decode the output
STOP_OUTPUT=$(echo "$ENCODED_OUTPUT" | base64 --decode 2>/dev/null)

echo "$STOP_OUTPUT"
echo

if [ $EXIT_CODE -eq 0 ]; then
  echo "PostgreSQL stopped successfully"
  echo
  echo "PostgreSQL has been stopped. Press Return to close this window."
else
  echo "Failed to stop PostgreSQL (exit code: $EXIT_CODE)"
  echo
  echo "Operation failed. Press Return to close this window."
fi

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
    do script "\"$TMP_SCRIPT\" \"$ENCODED_OUTPUT\" $EXIT_CODE"
    activate
end tell
EOF
