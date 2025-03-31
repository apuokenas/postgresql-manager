#!/bin/bash

# PostgreSQL Start Script for macOS
# 
# Author: Apuokėnas
# Version: v1.0
# Last changed: 2025-03-31
#
# Purpose: Starts PostgreSQL 17 server in the foreground
# 
# How it works:
# - Uses AppleScript to open a Terminal window
# - Runs the PostgreSQL server process directly with the postgres binary
# - Sets LC_ALL="C" to ensure consistent locale handling
# - Displays status messages based on success/failure

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

if [ ! -x "${PG_BINDIR}/postgres" ]; then
  handle_error "PostgreSQL server binary not executable"
fi

# Check if PostgreSQL is already running
if "${PG_BINDIR}/pg_ctl" -D "$PG_DATADIR" status &>/dev/null; then
  handle_error "PostgreSQL is already running"
fi

# Create temporary script with unique name in a persistent location
TMP_DIR="${HOME}/.postgres_scripts"
mkdir -p "$TMP_DIR"
TMP_SCRIPT="${TMP_DIR}/pg_start_$$_$(date +%s).sh"

# Write script content
cat > "$TMP_SCRIPT" << EOF
#!/bin/bash
clear
echo "Starting PostgreSQL ${PG_VERSION}..."
echo ""
LC_ALL="C" exec "${PG_BINDIR}/postgres" "-D" "${PG_DATADIR}" &
PG_PID=\$!
trap "kill \$PG_PID 2>/dev/null" EXIT

# Wait for a common signal to stop
echo "PostgreSQL is running. Press Ctrl+C to stop the server and close this window."
echo ""
wait \$PG_PID
echo "PostgreSQL has stopped. Press Return to close this window."
read -r

# Self-cleanup when done
rm -f "\$0"

# Use AppleScript to close the Terminal window
osascript -e 'tell application "Terminal" to close (every window whose frontmost is true)'
EOF

# Make it executable
chmod +x "$TMP_SCRIPT"

# Open Terminal and run the temporary script
osascript << EOF
tell application "Terminal"
    do script "\"$TMP_SCRIPT\""
    activate
end tell
EOF
