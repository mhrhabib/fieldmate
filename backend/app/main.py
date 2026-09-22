"""
Appliance Repair API — FastAPI backend.

Run locally:
    pip install -r requirements.txt
    uvicorn app.main:app --reload --port 8000

Docs at http://localhost:8000/docs once running.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .database import init_db
from .routers import customers, invoices, jobs

app = FastAPI(title="Appliance Repair API", version="0.1.0")

# Flutter's dev server picks a random localhost port, so CORS is wide open
# in dev. Lock this down to your real domain(s) before going to production.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(customers.router)
app.include_router(jobs.router)
app.include_router(invoices.router)


@app.on_event("startup")
def on_startup():
    init_db()


@app.get("/api/health")
def health():
    return {"status": "ok"}
