from flask import Flask
import socket
import os

app = Flask(__name__)

@app.route("/")
def index():
    hostname = socket.gethostname()
    environment = os.getenv("ENVIRONMENT", "dev")

    return f"""
    <h1>Cloud DevOps App</h1>
    <p><strong>Hostname:</strong> {hostname}</p>
    <p><strong>Environment:</strong> {environment}</p>
    """

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
