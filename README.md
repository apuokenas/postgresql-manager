# PostgreSQL Manager

A collection of user-friendly scripts for managing PostgreSQL on macOS with a simple double-click interface.

## Overview

This repository contains macOS command scripts that make PostgreSQL management visual and straightforward. Instead of remembering terminal commands, you can double-click these scripts to:

- **Start PostgreSQL** server with visible output
- **Stop PostgreSQL** server gracefully
- **Check PostgreSQL** server status

All operations run in dedicated Terminal windows with clear status messages and proper cleanup.

## Requirements

- macOS (any modern version)
- PostgreSQL 17 installed via [Homebrew](https://brew.sh)
  - `brew install postgresql@17`
- Default installation paths (customizable)

## Installation

1. Clone this repository:

```
git clone https://github.com/apuokenas/postgresql-manager.git
```

2. Make the scripts executable:

```bash
chmod +x *.command
```

3. Optional: Move scripts to a convenient location (Desktop, Applications folder, or Dock)

```bash
# Move to Applications folder (optional)
cp *.command "/Applications/PostgreSQL Manager/"
```


## Usage

### Starting the PostgreSQL Server

Double-click start_postgres.command:

- Opens a dedicated Terminal window
- Shows real-time server output
- Press Ctrl+C when you want to stop the server

### Checking PostgreSQL Status

Double-click check_postgres.command:

- Shows whether PostgreSQL is currently running
- Provides status information and exit code interpretation
- Useful for quick verification before performing operations

### Stopping the PostgreSQL Server

Double-click stop_postgres.command:

- Gracefully shuts down the running PostgreSQL server
- Shows shutdown status and confirmation
- The Terminal window automatically closes after acknowledgment

## How It Works

These scripts provide a user-friendly interface to PostgreSQL's command-line tools:

- Validate prerequisites before performing operations
- Create temporary execution scripts with proper error handling
- Use AppleScript for Terminal window management
- Clean up temporary resources automatically

## Customization

If you have a non-standard PostgreSQL installation, edit these variables at the top of each script:

```bash
PG_VERSION="17" # Change to your PostgreSQL version
PG_BINDIR="/usr/local/opt/postgresql@${PG_VERSION}/bin" # Path to binaries
PG_DATADIR="/usr/local/var/postgresql@${PG_VERSION}" # Path to data directory
```

## Troubleshooting

Common issues:

- **"PostgreSQL binaries not found"**: Verify your installation path or update the `PG_BINDIR` variable
- **"PostgreSQL is already running"**: Use check_postgres.command to verify status before starting
- **"PostgreSQL is not currently running"**: Server must be running before you can stop it
- **macOS security warnings**: Right-click the script and select "Open" for first-time execution

## Contributing

Contributions are welcome! Please feel free to submit pull requests with:

- Additional PostgreSQL management functionality
- UI improvements
- Documentation updates
- Bug fixes

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Apuokėnas © 2025
