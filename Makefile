.PHONY: dev

dev:
@docker compose up --build -d
@sleep 5
@docker compose exec backend python -m backend.app.manage migrate
@docker compose exec backend python -m backend.app.manage seed
@python -m webbrowser http://localhost:8080
