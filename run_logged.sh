#!/usr/bin/env bash
# Run the full solution quietly while logging progress to run.log
set -e

LOG_FILE="run.log"
# overwrite the log file each run
: > "$LOG_FILE"

# redirect all output to the log file
exec >>"$LOG_FILE" 2>&1

echo "=== Run started at $(date) ==="

# Build and run .NET console application
echo "[DOTNET BUILD]"
dotnet build src/ConsoleAppSolution.sln -c Release

echo "[DOTNET RUN]"
dotnet run --project src/ConsoleApp/ConsoleApp.csproj &
DOTNET_PID=$!

# Install Python backend dependencies
echo "[PIP INSTALL]"
pip install -r backend/requirements.txt

# Launch FastAPI backend
echo "[BACKEND RUN]"
python -m backend.app.main &
BACKEND_PID=$!

# Serve Vue frontend
echo "[FRONTEND SERVE]"
cd vue
python -m http.server &
FRONTEND_PID=$!
cd ..

cleanup() {
  echo "[CLEANUP]"
  kill $DOTNET_PID $BACKEND_PID $FRONTEND_PID
}
trap cleanup EXIT

wait
