from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from enum import Enum
from typing import Optional


class InvoiceStatus(str, Enum):
    UNPAID = "unpaid"
    PAID = "paid"


@dataclass
class InvoiceLineItem:
    description: str
    kind: str
    quantity: float
    unit_price: float


@dataclass
class Invoice:
    id: Optional[int]
    job_id: int
    status: InvoiceStatus
    line_items: list[InvoiceLineItem]
    created_at: Optional[datetime] = None
