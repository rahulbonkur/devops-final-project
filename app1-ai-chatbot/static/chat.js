document.addEventListener("DOMContentLoaded", () => {
    const chatBox = document.getElementById("chat-box");
    const userInput = document.getElementById("user-input");
    const sendBtn = document.getElementById("send-btn");
    const newChatBtn = document.getElementById("new-chat-btn");

    let sessionId = localStorage.getItem("chat_session_id");

    async function startNewSession() {
        const response = await fetch("/api/session/new", { method: "POST" });
        const data = await response.json();
        sessionId = data.session_id;
        localStorage.setItem("chat_session_id", sessionId);
        chatBox.innerHTML = "";
        appendMessage("assistant", "Hello! How can I help you today?");
    }

    if (!sessionId) {
        startNewSession();
    }

    newChatBtn.addEventListener("click", startNewSession);

    function appendMessage(role, text) {
        const msgDiv = document.createElement("div");
        msgDiv.classList.add("message", role === "user" ? "user-message" : "bot-message");
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
            const response = await fetch("/api/chat", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ session_id: sessionId, message: message })
            });

            const data = await response.json();
            if (data.response) {
                appendMessage("assistant", data.response);
            } else {
                appendMessage("assistant", "Error: Could not get response.");
            }
        } catch (error) {
            appendMessage("assistant", "Error: Network issue.");
        }
    }

    sendBtn.addEventListener("click", sendMessage);
    userInput.addEventListener("keypress", (e) => {
        if (e.key === "Enter") sendMessage();
    });
});
