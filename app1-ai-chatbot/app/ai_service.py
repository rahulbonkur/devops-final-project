import os
import requests

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"
GROQ_MODEL = os.getenv("GROQ_MODEL", "llama3-70b-8192")

def call_ai(messages):
    if not GROQ_API_KEY:
        raise Exception("GROQ_API_KEY environment variable is missing")

    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json"
    }

    payload = {
        "model": GROQ_MODEL,
        "messages": messages,
        "temperature": 0.7
    }

    response = requests.post(
        GROQ_API_URL,
        headers=headers,
        json=payload,
        timeout=30
    )

    response.raise_for_status()
    data = response.json()

    if "choices" not in data or not data["choices"]:
        raise Exception(f"Invalid response from Groq: {data}")

    return data["choices"][0]["message"]["content"]

