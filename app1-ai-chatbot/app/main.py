from flask import Flask
from flask_cors import CORS
from app.models import db
from app.routes import main_routes

def create_app():
    app = Flask(
        __name__,
        template_folder="../templates",
        static_folder="../static"
    )

    app.config["SECRET_KEY"] = "dev-secret-key"

    # ✅ ONLY in-memory DB for ECS
    app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///:memory:"
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    CORS(app)
    db.init_app(app)

    @app.route("/health")
    def health():
        return "OK", 200

    app.register_blueprint(main_routes)
    return app

# 🔥 Gunicorn entrypoint
app = create_app()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
