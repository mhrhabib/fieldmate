"""
Repairmate API — FastAPI backend.

The project is now organized around clean architecture boundaries so larger
future features can be added without coupling business logic to database and
HTTP implementations.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .database import init_db
from .interfaces.routes import router

app = FastAPI(title="Repairmate API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)


@app.on_event("startup")
def on_startup() -> None:
    init_db()
