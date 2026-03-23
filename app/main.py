import sqlite3
from flask import Flask, request, jsonify

app = Flask(__name__)

# hardcoded secret — GitLeaks will catch this
# AWS_SECRET_KEY = "AKIAIOSFODNN7EXAMPLE+wJalrXUtnFEMI/K7MDENG"
# DB_PASSWORD = "supersecret123"

@app.route('/users')
def get_users():
    username = request.args.get('username', '')
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    # SQL injection — SonarQube will catch this
    query = "SELECT * FROM users WHERE username = '" + username + "'"
    cursor.execute(query)
    return jsonify(cursor.fetchall())

@app.route('/health')
def health():
    return {"status": "ok"}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
