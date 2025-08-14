#!/usr/bin/env bash
set -euo pipefail

# Relaunch with sudo if not running as root. If sudo is unavailable continue
if [[ $EUID -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    echo "This script requires administrative privileges. Re-running with sudo..."
    exec sudo "$0" "$@"
  else
    echo "Warning: running without root privileges" >&2
  fi
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LOG_DIR="$ROOT/logs"
LOG_FILE="$LOG_DIR/run_all.log"
mkdir -p "$LOG_DIR"
export LOG_FILE

exec > >(tee -a "$LOG_FILE") 2>&1

error_handler() {
  local exit_code=$?
  echo "Error on line $1: $2 (exit code $exit_code)" >&2
}
trap 'error_handler ${LINENO} "$BASH_COMMAND"' ERR
trap "$ROOT/frank_down.sh" EXIT


"$ROOT/frank_up.sh"

# Helper to open the default browser on the correct platform
open_browser() {
  local url="http://localhost:8080"
  case "$(uname)" in
    Darwin*) cmd="open" ;;
    CYGWIN*|MINGW*|MSYS*) cmd="cmd.exe /c start" ;;
    *) cmd="xdg-open" ;;
  esac

  if command -v ${cmd%% *} >/dev/null 2>&1; then
    $cmd "$url" >/dev/null 2>&1 &
  else
    echo "Please open $url in your browser." >&2
  fi
}

echo
echo "Services are running. How would you like to open the UI?"
echo "1) Open in browser"
echo "2) Run Tauri application"
read -rp "Selection [1/2]: " choice

if [[ $choice == 2 ]]; then
  if command -v cargo >/dev/null 2>&1; then
    (cd "$ROOT/tauri" && cargo tauri dev)
    exit 0
  else
    echo "cargo not found - opening browser instead." >&2
  fi
fi

open_browser

echo "Press Ctrl+C to stop services."
while true; do sleep 1; done

