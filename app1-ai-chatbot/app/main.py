from flask import Flask
from flask_cors import CORS
from app.models import db
from app.routes import main_routes
import os

def create_app():
    app = Flask(
        __name__,
        template_folder="../templates",
        static_folder="../static"
    )

    app.config["SECRET_KEY"] = "dev-secret-key"
    app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///chatbot.db"
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    CORS(app)
    db.init_app(app)

    with app.app_context():
        db.create_all()

    # ✅ HEALTH CHECK ROUTE (ADD THIS)
    @app.route("/health")
    def health():
        return "OK", 200

    app.register_blueprint(main_routes)
    return app

app = create_app()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
    app = create_app()
