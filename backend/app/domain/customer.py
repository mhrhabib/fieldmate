from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class Customer:
    id: Optional[int]
    name: str
    phone: str
    email: Optional[str] = None
    address: Optional[str] = None
    created_at: Optional[datetime] = None
