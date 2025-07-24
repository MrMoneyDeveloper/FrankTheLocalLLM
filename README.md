# FrankTheLocalLLM

This repository contains a minimal front‑end built with Vue.js and Tailwind CSS plus a FastAPI backend and a .NET console application.

## Getting Started

1. Serve the Vue.js front-end from the `vue/` directory:
   ```bash
   cd vue && python -m http.server
   ```

2. In your browser open the served page. The client expects the FastAPI backend
   to be available at `http://localhost:8000/api`.

You can modify `vue/index.html` and `vue/app.js` to tweak the UI or add new
components.


## Backend API

A simple FastAPI backend is located in the `backend/` directory. The configuration uses environment variables via `pydantic` and enables CORS.

### Setup

1. Install Python 3.11 or newer.
2. Install dependencies:
   ```bash
   pip install -r backend/requirements.txt
   ```
3. Run the server:
   ```bash
   python -m backend.app.main
   ```

The server exposes a sample endpoint at `/api/hello` returning a welcome message.

### Trivia Chain Demo

The backend now includes a simple [LangChain](https://python.langchain.com) setup
that uses a local LLM provided by [Ollama](https://ollama.ai). A small knowledge
base lives in `backend/data/trivia.md` and is loaded into a vector store on
startup. When Ollama is running locally, you can query this data via:

```bash
curl "http://localhost:8000/api/trivia?q=What is the largest planet?"
```

Make sure to install the new Python dependencies and have an Ollama model (for
example `llama3`) available.


## Console Service

A .NET console application demonstrates SQLite data access using Dapper following a simple clean architecture layout. Projects reside in `src/`.

### Setup

1. Install the .NET SDK 8.0 or newer and verify the version:
   ```bash
   dotnet --version
   ```
   If the runtime loader complains about a different version (for example 9.0.1) install the matching SDK or update the `TargetFramework` in the project files.
2. Restore and build the solution (this also installs NuGet packages if needed):
   ```bash
   dotnet build src/ConsoleAppSolution.sln -c Release
   ```
3. Run the console app:
   ```bash
   dotnet run --project src/ConsoleApp/ConsoleApp.csproj
   ```

If `dotnet restore` warns that vulnerability data cannot be downloaded you can disable the audit by placing a `nuget.config` file next to the solution with:

```xml
<configuration>
  <config>
    <add key="VulnerabilityMode" value="Off" />
  </config>
</configuration>
```

By default the app stores data in `app.db`, creating the database if it does not exist.
The infrastructure project also exposes a `UserRepository` with async CRUD
operations powered by Dapper. Migration scripts under
`src/Infrastructure/Migrations` set up tables for `users`, `entries`, `tasks`
and `llm_logs`. A simple `user_stats` view provides aggregate counts which the
repository surfaces via `GetStatsAsync`.

## Dev Container

A `.devcontainer` configuration is provided for offline development.
It installs Python 3.11, Node.js, the .NET 8 SDK, SQLite and Ollama.
The container mounts a Docker volume at `/root/.ollama` so models and
database files persist between sessions.

Launch the environment with the [devcontainer CLI](https://containers.dev/cli):

```bash
devcontainer up
```

## Running Everything Together

To build and launch all parts of the project at once run:

```bash
./run_all.sh
```

This script sequentially builds the .NET console app, installs Python
dependencies and starts the FastAPI API, then serves the Vue.js front‑end.
The backend server stops automatically when you exit the HTTP server.

On Windows you can run the commands from `run_all.sh` in PowerShell or use
WSL to execute the script directly. Running them in order ensures all
dependencies are restored.

Background tasks that summarize entries can be started separately using

```bash
celery -A backend.app.tasks worker --beat
```



## Testing
Run `scripts/test_pipeline.sh` to lint frontend code, run vitest and pytest suites and apply SQL migrations in a container.
