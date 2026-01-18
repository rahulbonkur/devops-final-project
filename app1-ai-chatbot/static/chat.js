document.addEventListener("DOMContentLoaded", () => {
    const chatBox = document.getElementById("chat-box");
    const userInput = document.getElementById("user-input");
    const sendBtn = document.getElementById("send-btn");
    const newChatBtn = document.getElementById("new-chat-btn");

    // Initial bot message
    appendMessage("assistant", "Hello! How can I help you today?");

    newChatBtn.addEventListener("click", () => {
        chatBox.innerHTML = "";
        appendMessage("assistant", "Hello! How can I help you today?");
    });

    function appendMessage(role, text) {
        const msgDiv = document.createElement("div");
        msgDiv.classList.add("message");
        msgDiv.classList.add(role === "user" ? "user-message" : "bot-message");
        msgDiv.innerText = text;
        chatBox.appendChild(msgDiv);
        chatBox.scrollTop = chatBox.scrollHeight;
    }

    async function sendMessage() {
        const message = userInput.value.trim();
        if (!message) return;

        appendMessage("user", message);
        userInput.value = "";

        try {
            const response = await fetch("/chat", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({ message: message })
            });

            // Handle ALB / backend failures
            if (!response.ok) {
                appendMessage(
                    "assistant",
                    `Server error (${response.status}). Please try again.`
                );
                return;
            }

            const data = await response.json();

            if (data.response) {
                appendMessage("assistant", data.response);
            } else {
                appendMessage("assistant", "Sorry, I couldn't understand that.");
            }

        } catch (error) {
            console.error("Chat error:", error);
            appendMessage(
                "assistant",
                "Network issue. Please check your connection and try again."
            );
        }
    }

    sendBtn.addEventListener("click", sendMessage);

    userInput.addEventListener("keypress", (e) => {
        if (e.key === "Enter") {
            sendMessage();
        }
    });
});
