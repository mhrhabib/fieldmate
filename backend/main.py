"""
SiteMate API — FastAPI backend.

Run locally:
    pip install -r requirements.txt
    uvicorn main:app --reload --port 8000

This is a minimal starting point:
- CORS is open to your Astro dev server (http://localhost:4321) and build output.
- Data is stored in memory so it resets on restart — swap in PostgreSQL/SQLAlchemy
  (or SQLModel, since you're already using FastAPI) when you're ready.
- The two endpoints below (`/api/stats` and `/api/waitlist`) are exactly what the
  Astro starter in ../frontend calls, so you can see the full request flow.
"""

from datetime import datetime, timezone
from typing import List

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr

app = FastAPI(title="SiteMate API", version="0.1.0")

# In production, replace "*" with your real Astro domain(s), and read the list
# from an environment variable rather than hardcoding it.
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:4321",  # astro dev
        "http://127.0.0.1:4321",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class WaitlistEntry(BaseModel):
    email: EmailStr
    business_name: str | None = None


class WaitlistEntryOut(WaitlistEntry):
    created_at: datetime


# --- fake "database" for the demo -------------------------------------------------
_waitlist: List[WaitlistEntryOut] = []


@app.get("/api/health")
def health():
    return {"status": "ok"}


@app.get("/api/stats")
def stats():
    """
    Called by Astro at BUILD time (see frontend/src/pages/index.astro) to render
    a live-looking number into static HTML — good for SEO, since the number is
    already in the page source instead of being fetched client-side.
    """
    return {"waitlist_count": len(_waitlist)}


@app.post("/api/waitlist", response_model=WaitlistEntryOut, status_code=201)
def join_waitlist(entry: WaitlistEntry):
    if any(w.email == entry.email for w in _waitlist):
        raise HTTPException(status_code=409, detail="This email is already on the list.")
    record = WaitlistEntryOut(created_at=datetime.now(timezone.utc), **entry.model_dump())
    _waitlist.append(record)
    return record
