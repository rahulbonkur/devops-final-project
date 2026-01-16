from flask import Blueprint, request, jsonify, render_template
from datetime import datetime
import uuid
from app.models import db, ChatSession, Message
from app.ai_service import call_ai

main_routes = Blueprint("main_routes", __name__)

@main_routes.route("/")
def index():
    return render_template("chat.html")

@main_routes.route("/api/session/new", methods=["POST"])
def new_session():
    session_id = str(uuid.uuid4())
    db.session.add(ChatSession(id=session_id))
    db.session.commit()
    return jsonify({"session_id": session_id})

@main_routes.route("/api/chat", methods=["POST"])
def chat():
    data = request.json
    session_id = data.get("session_id")
    message = data.get("message")

    if not session_id or not message:
        return jsonify({"error": "Invalid request"}), 400

    db.session.add(Message(session_id=session_id, role="user", content=message))
    db.session.commit()

    history = Message.query.filter_by(session_id=session_id)\
        .order_by(Message.timestamp).all()

    messages = [{"role": m.role, "content": m.content} for m in history]
    reply = call_ai(messages)

    db.session.add(Message(session_id=session_id, role="assistant", content=reply))
    db.session.commit()

    return jsonify({"response": reply})

@main_routes.route("/health")
def health():
    return jsonify({"status": "healthy", "time": datetime.utcnow().isoformat()})
