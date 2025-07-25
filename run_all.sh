#!/usr/bin/env bash
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

# Build and run the .NET console application if dotnet is available
if command -v dotnet >/dev/null 2>&1; then
  dotnet build src/ConsoleAppSolution.sln -c Release
  dotnet run --project src/ConsoleApp/ConsoleApp.csproj &
  DOTNET_PID=$!
else
  echo "dotnet not found - skipping .NET build" >&2
  DOTNET_PID=
fi

# Install backend dependencies and launch the API

pip install -r backend/requirements.txt

python -m backend.app.main &
BACKEND_PID=$!

cleanup() {
  echo "Stopping backend..."
  [[ -n "$DOTNET_PID" ]] && kill "$DOTNET_PID"
  kill $BACKEND_PID
}
trap cleanup EXIT

# Serve the Vue.js frontend

cd vue
python -m http.server 8080
