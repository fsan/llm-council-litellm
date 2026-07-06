# Backend image: FastAPI app served by uvicorn (python -m backend.main)
FROM python:3.10-slim

# Install uv (matches the project's package manager + .python-version)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Install dependencies first for better layer caching.
# README.md is required because pyproject.toml declares readme = "README.md".
COPY pyproject.toml uv.lock README.md ./
RUN uv sync --frozen --no-dev

# Application code
COPY backend ./backend

# Conversations are written under DATA_DIR (data/conversations); persisted
# via the ./data volume mount in docker-compose.yml.
EXPOSE 8001

CMD ["uv", "run", "python", "-m", "backend.main"]