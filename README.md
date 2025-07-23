# FrankTheLocalLLM

This repository contains a minimal Flutter project configured with [responsive_framework](https://pub.dev/packages/responsive_framework) to provide adaptive layouts across devices. The project also includes the web folder so it can be built and served as a web application.

## Getting Started

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) on your machine.

2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application in Chrome:
   ```bash
   flutter run -d chrome
   ```

You can modify `lib/main.dart` to adjust breakpoints or add additional widgets.


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

1. Install the .NET SDK 8.0 or newer.
2. Restore and build the solution:
   ```bash
   dotnet build src/ConsoleAppSolution.sln -c Release
   ```
3. Run the console app:
   ```bash
   dotnet run --project src/ConsoleApp/ConsoleApp.csproj
   ```

By default the app stores data in `app.db`, creating the database if it does not exist.

## Dev Container

A `.devcontainer` configuration is provided for offline development.
It installs Python 3.11, Flutter, the .NET 8 SDK, SQLite and Ollama.
The container mounts a Docker volume at `/root/.ollama` so models and
database files persist between sessions.

Launch the environment with the [devcontainer CLI](https://containers.dev/cli):

```bash
devcontainer up
```


