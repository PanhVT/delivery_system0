"""
db_connection.py - Database connection manager using mysql-connector-python
"""

import mysql.connector
from mysql.connector import Error
from contextlib import contextmanager

# ── Database configuration ────────────────────────────────────────────────────
DB_CONFIG = {
    "host":     "localhost",
    "port":     3306,
    "database": "delivery_system",
    "user":     "root",        # change to appropriate user
    "password": "Laphanh11",
    "charset":  "utf8mb4",
    "autocommit": False,
    "connect_timeout": 10,
}


def get_connection():
    """Return a new MySQL connection."""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        raise ConnectionError(f"[DB] Cannot connect: {e}")


@contextmanager
def get_cursor(dictionary=True):
    """
    Context manager: yields (connection, cursor), auto-commits on success,
    rolls back on exception, and always closes resources.

    Usage:
        with get_cursor() as (conn, cur):
            cur.execute("SELECT ...")
            rows = cur.fetchall()
    """
    conn = get_connection()
    cur  = conn.cursor(dictionary=dictionary)
    try:
        yield conn, cur
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()


def test_connection():
    """Quick connectivity test; returns True/False."""
    try:
        conn = get_connection()
        conn.close()
        return True
    except ConnectionError:
        return False
    

