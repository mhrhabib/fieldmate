"""
Database engine and session management.

Uses SQLModel (SQLAlchemy + Pydantic in one) so the same class can serve as
both the ORM model and the API schema for simple cases.

DATABASE_URL defaults to a local SQLite file so you can run this immediately
with zero setup. Swap to Postgres for anything beyond local dev — just point
DATABASE_URL at it, e.g.:
    postgresql+psycopg://user:password@localhost:5432/appliance_repair
"""

import os
from collections.abc import Generator

from sqlmodel import Session, SQLModel, create_engine

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./appliance_repair.db")

connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}
engine = create_engine(DATABASE_URL, echo=False, connect_args=connect_args)


def init_db() -> None:
    """Create tables from models. Fine for an MVP; move to Alembic migrations
    once the schema needs to change without dropping data."""
    SQLModel.metadata.create_all(engine)


def get_session() -> Generator[Session, None, None]:
    with Session(engine) as session:
        yield session
