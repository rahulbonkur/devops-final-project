import os
import requests

ANTHROPIC_API_KEY = os.getenv('ANTHROPIC_API_KEY')
ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages"

def call_ai(messages):
    headers = {
        "x-api-key": ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json"
    }

    payload = {
        "model": "claude-sonnet-4-20250514",
        "max_tokens": 1024,
        "messages": messages
    }

    response = requests.post(
        ANTHROPIC_API_URL,
        headers=headers,
        json=payload,
        timeout=30
    )

    return response.json()['content'][0]['text']
