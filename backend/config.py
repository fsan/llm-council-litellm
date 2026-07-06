"""Configuration for the LLM Council."""

import os
from dotenv import load_dotenv

load_dotenv()

# LiteLLM proxy API key (bearer token sent to the proxy; must equal the
# proxy's LITELLM_MASTER_KEY). The proxy holds the real per-provider keys.
LITELLM_API_KEY = os.getenv("LITELLM_API_KEY")

# Council members - model aliases exposed by the LiteLLM proxy.
# See litellm_config.yaml for the provider routing behind each alias.
#    "ollama/glm-5.2:cloud",
COUNCIL_MODELS = [
    "ollama/glm-5.2:cloud",
    "ollama/deepseek-v4-flash:cloud",
    "ollama/qwen3.5:cloud",
    "ollama/gemma4:cloud",
]

# Chairman model - synthesizes the final response
CHAIRMAN_MODEL = "ollama/deepseek-v4-pro:cloud"

# Cheap/fast model used to generate short conversation titles
TITLE_MODEL = "ollama/gemma4:cloud"

# LiteLLM proxy chat-completions endpoint. Inside docker-compose the proxy
# is reachable at http://litellm-proxy:4000; override via env for local runs.
LITELLM_API_URL = os.getenv(
    "LITELLM_API_URL",
    "http://litellm-proxy:4000/v1/chat/completions",
)

# Data directory for conversation storage
DATA_DIR = "data/conversations"
