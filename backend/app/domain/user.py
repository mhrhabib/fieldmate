from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class User:
    id: Optional[int]
    name: str
    email: str
    hashed_password: str
    created_at: Optional[datetime] = None
