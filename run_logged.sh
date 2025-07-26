#!/usr/bin/env bash
# Run the full solution quietly while logging progress to run.log
set -e

# Relaunch with sudo if not running as root. If sudo is unavailable continue
if [[ $EUID -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    echo "This script requires administrative privileges. Re-running with sudo..."
    exec sudo "$0" "$@"
  else
    echo "Warning: running without root privileges" >&2
  fi
fi

# Ensure the backend port is free before starting
free_port() {
  local port=$1
  if lsof -ti tcp:"$port" > /dev/null 2>&1; then
    echo "Port $port in use - terminating process"
    lsof -ti tcp:"$port" | xargs kill -9
  fi
}

free_port 8000

LOG_FILE="run.log"
# overwrite the log file each run
: > "$LOG_FILE"

# redirect all output to both stdout and the log file
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Run started at $(date) ==="

# Build and run .NET console application
echo "[DOTNET BUILD]"
if command -v dotnet >/dev/null 2>&1; then
  dotnet build src/ConsoleAppSolution.sln -c Release

  echo "[DOTNET RUN]"
  dotnet run --project src/ConsoleApp/ConsoleApp.csproj &
  DOTNET_PID=$!
else
  echo "dotnet not found - skipping .NET build" >&2
  DOTNET_PID=
fi

# Install Python backend dependencies
echo "[PIP INSTALL]"
pip install -r backend/requirements.txt

# Launch FastAPI backend
echo "[BACKEND RUN]"
python -m backend.app.main &
BACKEND_PID=$!

# Serve Vue frontend
echo "[FRONTEND SERVE]"
  cd app
  python -m http.server 8080 &
  FRONTEND_PID=$!
cd ..

cleanup() {
  echo "[CLEANUP]"
  [[ -n "$DOTNET_PID" ]] && kill "$DOTNET_PID"
  kill $BACKEND_PID $FRONTEND_PID
}
trap cleanup EXIT

wait
