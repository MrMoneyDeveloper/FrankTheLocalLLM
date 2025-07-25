#!/usr/bin/env bash
set -e

# Ensure the backend port is free before starting
free_port() {
  local port=$1
  if lsof -ti tcp:"$port" > /dev/null 2>&1; then
    echo "Port $port in use - terminating process"
    lsof -ti tcp:"$port" | xargs kill -9
  fi
}

free_port 8000

# Build and run the .NET console application

dotnet build src/ConsoleAppSolution.sln -c Release

dotnet run --project src/ConsoleApp/ConsoleApp.csproj

# Install backend dependencies and launch the API

pip install -r backend/requirements.txt

python -m backend.app.main &
BACKEND_PID=$!

cleanup() {
  echo "Stopping backend..."
  kill $BACKEND_PID
}
trap cleanup EXIT

# Serve the Vue.js frontend

cd vue
python -m http.server 8080
