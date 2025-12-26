from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def home():
    return "Automated Containerized Web App running on AWS ECS"

@app.route("/health")
def health():
    return "OK"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
