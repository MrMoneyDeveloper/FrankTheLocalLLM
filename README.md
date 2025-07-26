# FrankTheLocalLLM

FrankTheLocalLLM combines a Vue.js + Tailwind front‑end with a FastAPI backend and a small .NET console application. It demonstrates how to run a local language‑model driven notes app with background processing and optional desktop packaging.

## Features

- Vue front‑end served via a simple HTTP server
- FastAPI API exposing chat, retrieval and import endpoints
- LangChain integration with a local Ollama model
- Background tasks using Celery and Redis
- Example .NET console service with SQLite and Dapper
- Docker Compose stack including Postgres with pgvector
- Devcontainer configuration for offline development

## Process Overview

1. The Vue front‑end sends requests to the FastAPI backend under `/api`.
2. Notes are chunked and embedded into Postgres using pgvector.
3. Retrieval endpoints stream answers from the vector store via LangChain.
4. Background workers summarize entries and maintain backlinks.
5. The optional .NET console app demonstrates additional data access patterns.

## Documentation

- [Local Development Guide](docs/README-local-dev.md) explains how to run everything unpackaged.
- [Packaging Guide](docs/README-packaging.md) covers building desktop bundles or Docker images.

Run `scripts/test_pipeline.sh` to lint and test the codebase.
