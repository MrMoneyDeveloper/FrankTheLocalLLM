#!/usr/bin/env bash
set -euo pipefail

# --- Project policy ---
# NO DOCKER: This project does not use Docker or containers.
# One-command bring-up: this script installs missing deps, configures, and runs services.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"
mkdir -p logs

# --- Helpers ---
# Return 0 if the given command exists, else non-zero
need_cmd() { command -v "$1" >/dev/null 2>&1; }
apt_has() { dpkg -s "$1" >/dev/null 2>&1; }

log() { printf "\n==== %s ====\n" "$*"; }

# --- Detect Ubuntu/WSL ---
# /etc/os-release may be missing in minimal environments; check before grepping
if [[ ! -r /etc/os-release ]] || ! grep -qi ubuntu /etc/os-release; then
  echo "This bootstrap is tailored for Ubuntu. For other OS, ask me for the macOS/Windows variant."
  exit 1
fi

# --- Update apt once ---
log "Updating apt"
sudo apt-get update -y

# --- Git (usually present) ---
if ! need_cmd git; then
  log "Installing git"
  sudo apt-get install -y git
fi

# --- Python + venv + pip ---
if ! need_cmd python3; then
  log "Installing Python 3"
  sudo apt-get install -y python3
fi
if ! python3 -c "import venv" 2>/dev/null; then
  log "Installing python3-venv"
  sudo apt-get install -y python3-venv
fi
if ! need_cmd pip3; then
  log "Installing pip"
  sudo apt-get install -y python3-pip
fi

# --- Node.js + npm (skip if present) ---
if ! need_cmd node || ! need_cmd npm; then
  log "Installing Node.js & npm (Ubuntu repos)"
  sudo apt-get install -y nodejs npm
fi

# --- Redis server + redis-cli ---
if ! need_cmd redis-server || ! need_cmd redis-cli; then
  log "Installing redis-server and redis-tools"
  sudo apt-get install -y redis-server redis-tools
fi
log "Enabling & starting redis-server"
sudo systemctl enable --now redis-server
sleep 1
redis-cli PING | grep -qi PONG || { echo "Redis not responding to PING"; exit 1; }

# --- Ollama (local LLM) ---
if ! need_cmd ollama; then
  log "Installing Ollama"
  curl -fsSL https://ollama.com/install.sh | sh
fi
# Start Ollama service if available; else run in user session
if systemctl list-unit-files | grep -q '^ollama\.service'; then
  log "Enabling & starting ollama service"
  sudo systemctl enable --now ollama
else
  log "Starting ollama daemon in background"
  nohup ollama serve > logs/ollama.log 2>&1 &
  echo $! > logs/ollama.pid
  sleep 2
fi
# Ensure model present
if ! ollama list | awk '{print $1}' | grep -qx "llama3"; then
  log "Pulling model: llama3"
  ollama pull llama3
fi

# --- Python venv + deps ---
log "Setting up Python virtualenv"
python3 -m venv .venv
# shellcheck source=/dev/null
source .venv/bin/activate
pip install --upgrade pip
pip install -r backend/requirements.txt

# --- .env defaults (no Postgres; SQLite for local dev) ---
log "Creating .env (if absent)"
if [[ ! -f .env ]]; then
  cat > .env <<'EOF'
PORT=8000
REDIS_URL=redis://localhost:6379/0
DATABASE_URL=sqlite:///./app.db
MODEL=llama3
DEBUG=false
EOF
fi

# --- Start backend ---
log "Starting backend"
# Export .env variables for child processes
set -a; source .env; set +a
nohup python -m backend.app.main > logs/backend.log 2>&1 &
echo $! > logs/backend.pid

# Wait for /api/hello
log "Waiting for backend health"
for i in {1..30}; do
  if curl -fsS "http://localhost:${PORT:-8000}/api/hello" >/dev/null 2>&1; then
    echo "Backend healthy at http://localhost:${PORT:-8000}"
    break
  fi
  sleep 1
done

# --- Start Celery (worker+beat) ---
log "Starting Celery worker+beat"
nohup celery -A backend.app.tasks worker --beat > logs/celery.log 2>&1 &
echo $! > logs/celery.pid
sleep 1

# --- Serve frontend (vue/ preferred, else app/) ---
FRONT_DIR=""
if [[ -d "vue" ]]; then FRONT_DIR="vue"; elif [[ -d "app" ]]; then FRONT_DIR="app"; fi
if [[ -z "$FRONT_DIR" ]]; then
  echo "No frontend directory (vue/ or app/) found."; exit 1
fi

log "Serving frontend from $FRONT_DIR on http://localhost:8080"
pushd "$FRONT_DIR" >/dev/null
nohup python -m http.server 8080 > "$ROOT/logs/frontend.log" 2>&1 &
echo $! > "$ROOT/logs/frontend.pid"
popd >/dev/null

# --- Summary ---
log "Summary"
echo "OS            : Ubuntu"
echo "Python        : $(python3 --version 2>/dev/null || echo n/a)"
echo "Node/npm      : $(node -v 2>/dev/null || echo n/a) / $(npm -v 2>/dev/null || echo n/a)"
echo "Redis         : $(redis-server --version 2>/dev/null | awk '{print $3}' || echo n/a)"
echo "Ollama        : $(ollama --version 2>/dev/null || echo n/a)"
echo "Model         : ${MODEL:-llama3}"
echo "Backend URL   : http://localhost:${PORT:-8000}/api"
echo "Frontend URL  : http://localhost:8080"
echo "PIDs          : backend($(cat logs/backend.pid)), celery($(cat logs/celery.pid)), frontend($(cat logs/frontend.pid))"
[[ -f logs/ollama.pid ]] && echo "Ollama PID    : $(cat logs/ollama.pid) (user session)"

log "Health checks"
set +e
curl -fsS "http://localhost:${PORT:-8000}/api/hello" && echo
curl -fsS "http://localhost:${PORT:-8000}/api/trivia?q=What%20is%20the%20largest%20planet?" && echo
set -e

echo -e "\nAll set. Open: http://localhost:8080"
