"""
Data models for the appliance-repair MVP.

Deliberately minimal — one tech/shop owner per account, no multi-tech
dispatch yet. Add that in v2 once real customers ask for it.
"""

from datetime import datetime, timezone
from enum import Enum
from typing import Optional

from sqlmodel import Field, Relationship, SQLModel


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


# ---------------------------------------------------------------------------
# Customer
# ---------------------------------------------------------------------------
class CustomerBase(SQLModel):
    name: str
    phone: str
    email: Optional[str] = None
    address: Optional[str] = None


class Customer(CustomerBase, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=utcnow)

    jobs: list["Job"] = Relationship(back_populates="customer")


class CustomerCreate(CustomerBase):
    pass


class CustomerRead(CustomerBase):
    id: int
    created_at: datetime


# ---------------------------------------------------------------------------
# Job — this is the piece generic FSM tools get wrong for appliance repair
# ---------------------------------------------------------------------------
class JobStatus(str, Enum):
    lead = "lead"
    scheduled = "scheduled"
    in_progress = "in_progress"
    waiting_on_part = "waiting_on_part"   # the status generic tools don't have
    completed = "completed"
    invoiced = "invoiced"
    paid = "paid"


class JobBase(SQLModel):
    appliance_type: str          # e.g. "Refrigerator", "Washer", "Dryer"
    brand: Optional[str] = None
    model_number: Optional[str] = None
    serial_number: Optional[str] = None
    symptom: str                 # what the customer reported
    diagnosis: Optional[str] = None
    status: JobStatus = JobStatus.lead
    scheduled_at: Optional[datetime] = None
    notes: Optional[str] = None
    part_needed: Optional[str] = None   # filled in when status = waiting_on_part
    part_eta: Optional[datetime] = None


class Job(JobBase, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    customer_id: int = Field(foreign_key="customer.id")
    # If this job is a return visit for the same appliance issue, link it back
    # to the original job. This is how you get a first-time-fix / callback
    # rate — something no generic FSM tool tracks natively.
    original_job_id: Optional[int] = Field(default=None, foreign_key="job.id")
    created_at: datetime = Field(default_factory=utcnow)
    updated_at: datetime = Field(default_factory=utcnow)

    customer: Customer = Relationship(back_populates="jobs")
    invoice: Optional["Invoice"] = Relationship(back_populates="job")


class JobCreate(JobBase):
    customer_id: int
    original_job_id: Optional[int] = None


class JobRead(JobBase):
    id: int
    customer_id: int
    original_job_id: Optional[int] = None
    created_at: datetime
    updated_at: datetime


class JobUpdate(SQLModel):
    """All fields optional — used for PATCH-style partial updates
    (e.g. just moving status to waiting_on_part and setting part_needed)."""
    appliance_type: Optional[str] = None
    brand: Optional[str] = None
    model_number: Optional[str] = None
    serial_number: Optional[str] = None
    symptom: Optional[str] = None
    diagnosis: Optional[str] = None
    status: Optional[JobStatus] = None
    scheduled_at: Optional[datetime] = None
    notes: Optional[str] = None
    part_needed: Optional[str] = None
    part_eta: Optional[datetime] = None


# ---------------------------------------------------------------------------
# Invoice
# ---------------------------------------------------------------------------
class LineItemKind(str, Enum):
    labor = "labor"
    part = "part"


class InvoiceLineItemBase(SQLModel):
    description: str
    kind: LineItemKind
    quantity: float = 1
    unit_price: float


class InvoiceLineItem(InvoiceLineItemBase, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    invoice_id: int = Field(foreign_key="invoice.id")

    invoice: "Invoice" = Relationship(back_populates="line_items")


class InvoiceLineItemCreate(InvoiceLineItemBase):
    pass


class InvoiceStatus(str, Enum):
    unpaid = "unpaid"
    paid = "paid"


class Invoice(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    job_id: int = Field(foreign_key="job.id", unique=True)
    status: InvoiceStatus = InvoiceStatus.unpaid
    created_at: datetime = Field(default_factory=utcnow)

    job: Job = Relationship(back_populates="invoice")
    line_items: list[InvoiceLineItem] = Relationship(back_populates="invoice")


class InvoiceCreate(SQLModel):
    job_id: int
    line_items: list[InvoiceLineItemCreate]


class InvoiceRead(SQLModel):
    id: int
    job_id: int
    status: InvoiceStatus
    created_at: datetime
    line_items: list[InvoiceLineItemBase]
    total: float
