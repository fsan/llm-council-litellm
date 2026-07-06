# LLM Council

![llmcouncil](header.jpg)

The idea of this repo is that instead of asking a question to your favorite LLM provider (e.g. OpenAI GPT-5-mini, Ollama Cloud GLM/DeepSeek/Qwen, etc.), you can group them into your "LLM Council". This repo is a simple, local web app that essentially looks like ChatGPT except it uses a [LiteLLM](https://litellm.ai) proxy to send your query to multiple LLMs, it then asks them to review and rank each other's work, and finally a Chairman LLM produces the final response.

In a bit more detail, here is what happens when you submit a query:

1. **Stage 1: First opinions**. The user query is given to all LLMs individually, and the responses are collected. The individual responses are shown in a "tab view", so that the user can inspect them all one by one.
2. **Stage 2: Review**. Each individual LLM is given the responses of the other LLMs. Under the hood, the LLM identities are anonymized so that the LLM can't play favorites when judging their outputs. The LLM is asked to rank them in accuracy and insight.
3. **Stage 3: Final response**. The designated Chairman of the LLM Council takes all of the model's responses and compiles them into a single final answer that is presented to the user.

## Vibe Code Alert

This project was 99% vibe coded as a fun Saturday hack because I wanted to explore and evaluate a number of LLMs side by side in the process of [reading books together with LLMs](https://x.com/karpathy/status/1990577951671509438). It's nice and useful to see multiple responses side by side, and also the cross-opinions of all LLMs on each other's outputs. I'm not going to support it in any way, it's provided here as is for other people's inspiration and I don't intend to improve it. Code is ephemeral now and libraries are over, ask your LLM to change it in whatever way you like.

## Setup

The app runs as three Docker services: a **LiteLLM proxy** (gateway to the LLM providers), the **FastAPI backend**, and the **frontend** (Vite SPA served by nginx).

### 1. Configure secrets

Copy `.env.example` to `.env` and fill in your keys:

```bash
cp .env.example .env
```

```bash
# LLM provider keys (consumed by the litellm-proxy container)
OPENAI_API_KEY=sk-...                              # https://platform.openai.com
OLLAMA_API_KEY=...                                 # https://ollama.com/settings/keys (Cloud is metered)
# LiteLLM proxy master key — the backend uses the SAME value as its bearer token
LITELLM_MASTER_KEY=sk-litellm-master-change-me
LITELLM_API_KEY=sk-litellm-master-change-me        # must equal LITELLM_MASTER_KEY
```

The proxy routes each council model alias to its provider via `litellm_config.yaml`. Ollama Cloud models use the OpenAI-compatible endpoint at `https://ollama.com/v1` (note: `api.ollama.com` does **not** work).

### 2. Configure Models (Optional)

The council, chairman, and title models are defined in `backend/config.py` and must match the `model_name` aliases in `litellm_config.yaml`:

```python
COUNCIL_MODELS = [
    "ollama/glm-5.2:cloud",
    "ollama/deepseek-v4-pro:cloud",
    "ollama/qwen-3.5:cloud",
    "openai/gpt-5-mini",
]

CHAIRMAN_MODEL = "openai/gpt-5-mini"
TITLE_MODEL = "ollama/glm-5.2:cloud"
```

If a model tag is unavailable on its provider, swap it in both `litellm_config.yaml` and `backend/config.py`. Available Ollama Cloud tags are listed at `ollama.com/search?c=cloud`. The backend degrades gracefully per model, so a single failing model won't break a run.

## Running the Application

**Option 1: Docker (recommended)**

```bash
docker compose build
docker compose up
```

Then open http://localhost:5173 in your browser. The backend API is at http://localhost:8001 and the LiteLLM proxy at http://localhost:4000 (useful for direct testing). Conversations persist in the `./data` volume.

Smoke-test a model alias directly against the proxy:

```bash
curl http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"openai/gpt-5-mini","messages":[{"role":"user","content":"hi"}]}'
```

**Option 2: Run manually without Docker** (requires `uv` + Node)

Terminal 1 (Backend):
```bash
uv sync
LITELLM_API_URL=http://localhost:4000/v1/chat/completions uv run python -m backend.main
```

Terminal 2 (Frontend):
```bash
cd frontend
npm install
npm run dev
```

You'll also need to run a LiteLLM proxy locally (e.g. `litellm --config litellm_config.yaml --port 4000`) and the same `.env` keys. Then open http://localhost:5173.

## Tech Stack

- **Backend:** FastAPI (Python 3.10+), async httpx, LiteLLM proxy API
- **Frontend:** React + Vite, react-markdown for rendering
- **LLM Gateway:** LiteLLM proxy (Ollama Cloud + OpenAI)
- **Storage:** JSON files in `data/conversations/`
- **Package Management:** uv for Python, npm for JavaScript
