import os
import requests

# Ollama configuration
OLLAMA_API_URL = os.getenv('OLLAMA_API_URL', 'http://localhost:11434/api/chat')
OLLAMA_MODEL = os.getenv('OLLAMA_MODEL', 'openchat')

def call_ai(messages):
    """
    Call Ollama API for chat completion.
    Assumes Ollama is running locally at localhost:11434
    Model: openchat (as per user requirement)
    """
    headers = {
        "content-type": "application/json"
    }

    # Format messages for Ollama API
    # Ollama expects messages in the format: [{"role": "user", "content": "..."}, ...]
    formatted_messages = messages
    
    payload = {
        "model": OLLAMA_MODEL,
        "messages": formatted_messages,
        "stream": False  # Non-streaming response
    }

    try:
        response = requests.post(
            OLLAMA_API_URL,
            headers=headers,
            json=payload,
            timeout=60  # Increased timeout for local model inference
        )
        response.raise_for_status()
        
        response_data = response.json()
        
        # Ollama response format: {"message": {"role": "assistant", "content": "..."}}
        if 'message' in response_data and 'content' in response_data['message']:
            return response_data['message']['content']
        elif 'content' in response_data:
            # Fallback for different response formats
            return response_data['content']
        else:
            raise ValueError(f"Invalid response format from Ollama API: {response_data}")
    except requests.exceptions.ConnectionError as e:
        raise Exception(f"Cannot connect to Ollama. Make sure Ollama is running at {OLLAMA_API_URL}. Run: ollama serve")
    except requests.exceptions.Timeout as e:
        raise Exception(f"Ollama request timed out. The model might be processing. Try again.")
    except requests.exceptions.RequestException as e:
        raise Exception(f"Ollama API request failed: {str(e)}")
    except (KeyError, IndexError) as e:
        raise Exception(f"Failed to parse Ollama API response: {str(e)}")
