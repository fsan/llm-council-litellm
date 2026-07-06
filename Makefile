.PHONY: up down restart logs ps clean help

# Default target
help:
	@echo "LLM Council (LiteLLM) targets:"
	@echo "  make up      - ensure .env, (re)build images, pull latest base images, start all services"
	@echo "  make down    - stop and remove containers/network (keeps ./data)"
	@echo "  make restart - restart all services"
	@echo "  make logs    - tail logs (Ctrl+C to exit)"
	@echo "  make ps      - show service status"
	@echo "  make clean   - down + remove dangling build cache/images"

# `up`: ensure secrets exist, rebuild any changed images, refresh base images,
# and start the stack detached. Re-runnable: it updates files/images on each call.
up:
	@if [ ! -f .env ]; then \
		echo ">> .env not found, creating from .env.example (edit before first run!)"; \
		cp .env.example .env; \
	fi
	@echo ">> Pulling latest base images..."
	docker compose pull
	@echo ">> Building images and (re)creating containers (forces proxy config reload)..."
	docker compose up -d --build --force-recreate
	@echo ">> Frontend: http://localhost:5173  |  Backend: http://localhost:8001  |  Proxy: http://localhost:4000"

# `down`: stop and remove containers + network. Volumes (./data) are preserved.
down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f --tail=200

ps:
	docker compose ps

clean: down
	docker image prune -f