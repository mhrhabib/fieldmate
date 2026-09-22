from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from enum import Enum
from typing import Optional


class JobStatus(str, Enum):
    LEAD = "lead"
    SCHEDULED = "scheduled"
    IN_PROGRESS = "in_progress"
    WAITING_ON_PART = "waiting_on_part"
    COMPLETED = "completed"
    INVOICED = "invoiced"
    PAID = "paid"


@dataclass
class Job:
    id: Optional[int]
    customer_id: int
    appliance_type: str
    brand: Optional[str]
    model_number: Optional[str]
    serial_number: Optional[str]
    symptom: str
    diagnosis: Optional[str]
    status: JobStatus
    scheduled_at: Optional[datetime]
    notes: Optional[str] = None
    part_needed: Optional[str] = None
    part_eta: Optional[datetime] = None
    original_job_id: Optional[int] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
