from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select

from ..database import get_session
from ..models import (
    Invoice,
    InvoiceCreate,
    InvoiceLineItem,
    InvoiceRead,
    InvoiceStatus,
    Job,
    JobStatus,
)

router = APIRouter(prefix="/api/invoices", tags=["invoices"])


def _to_read(invoice: Invoice) -> InvoiceRead:
    total = sum(li.quantity * li.unit_price for li in invoice.line_items)
    return InvoiceRead(
        id=invoice.id,
        job_id=invoice.job_id,
        status=invoice.status,
        created_at=invoice.created_at,
        line_items=invoice.line_items,
        total=round(total, 2),
    )


@router.post("/", response_model=InvoiceRead, status_code=201)
def create_invoice(payload: InvoiceCreate, session: Session = Depends(get_session)):
    job = session.get(Job, payload.job_id)
    if not job:
        raise HTTPException(404, "Job not found")

    invoice = Invoice(job_id=payload.job_id)
    session.add(invoice)
    session.flush()  # get invoice.id before attaching line items

    for item in payload.line_items:
        session.add(InvoiceLineItem(invoice_id=invoice.id, **item.model_dump()))

    job.status = JobStatus.invoiced
    session.add(job)

    session.commit()
    session.refresh(invoice)
    return _to_read(invoice)


@router.get("/{invoice_id}", response_model=InvoiceRead)
def get_invoice(invoice_id: int, session: Session = Depends(get_session)):
    invoice = session.get(Invoice, invoice_id)
    if not invoice:
        raise HTTPException(404, "Invoice not found")
    return _to_read(invoice)


@router.post("/{invoice_id}/mark-paid", response_model=InvoiceRead)
def mark_paid(invoice_id: int, session: Session = Depends(get_session)):
    invoice = session.get(Invoice, invoice_id)
    if not invoice:
        raise HTTPException(404, "Invoice not found")

    invoice.status = InvoiceStatus.paid
    job = session.get(Job, invoice.job_id)
    job.status = JobStatus.paid

    session.add(invoice)
    session.add(job)
    session.commit()
    session.refresh(invoice)
    return _to_read(invoice)
