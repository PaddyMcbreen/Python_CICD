import sqlite3

DATABASE = 'scores.db'

def get_db():
    conn = sqlite3.connect(DATABASE)
    return conn

def init_db():
    conn = get_db()
    with open('schema.sql', mode='r') as f:
        conn.cursor().executescript(f.read())
    conn.commit()
    conn.close()

def save_score(attempts):
    conn = get_db()
    cur = conn.cursor()
    cur.execute('INSERT INTO scores (attempts) VALUES (?)', (attempts,))
    conn.commit()
    conn.close()
