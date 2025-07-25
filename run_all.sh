#!/usr/bin/env bash
set -e

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
