"""
Database reset and re-initialization utility script for Repairmate backend.

Usage:
    python reset_db.py

This script safely removes any existing local SQLite test database
(appliance_repair.db) and re-creates all tables according to SQLModel definitions.
"""

import os
import sys

# Ensure backend root is on Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.database import engine, init_db
from sqlmodel import SQLModel


def reset_database() -> None:
    print("Resetting Repairmate database...")

    # Drop all existing tables and dispose connections
    try:
        SQLModel.metadata.drop_all(engine)
    except Exception:
        pass

    engine.dispose()
    print("Dropped tables and disposed engine connection pool.")

    # Remove SQLite file if present
    db_paths = ["appliance_repair.db", "app/appliance_repair.db", "./appliance_repair.db"]
    for path in db_paths:
        if os.path.exists(path):
            try:
                os.remove(path)
                print(f"Removed database file: {path}")
            except OSError as exc:
                print(f"Warning: Could not remove {path}: {exc}")

    # Re-initialize tables cleanly
    init_db()
    print("Database tables initialized successfully!")


if __name__ == "__main__":
    reset_database()
