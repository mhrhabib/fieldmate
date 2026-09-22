from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session

from ..application.customer_service import CustomerService
from ..application.invoice_service import InvoiceService
from ..application.job_service import JobService
from ..database import get_session
from ..infrastructure.repositories.customer_repository import CustomerRepository
from ..infrastructure.repositories.invoice_repository import InvoiceRepository
from ..infrastructure.repositories.job_repository import JobRepository
from ..domain.job import JobStatus

router = APIRouter()


def get_customer_service(session: Session = Depends(get_session)) -> CustomerService:
    return CustomerService(CustomerRepository(session))


def get_job_service(session: Session = Depends(get_session)) -> JobService:
    return JobService(JobRepository(session))


def get_invoice_service(session: Session = Depends(get_session)) -> InvoiceService:
    return InvoiceService(InvoiceRepository(session))


@router.get("/api/health")
def health() -> dict:
    return {"status": "ok"}


@router.get("/api/customers")
def list_customers(service: CustomerService = Depends(get_customer_service)):
    return service.get_all()


@router.post("/api/customers")
def create_customer(payload: dict, service: CustomerService = Depends(get_customer_service)):
    try:
        return service.create(payload)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/api/jobs")
def list_jobs(
    status: JobStatus | None = Query(default=None),
    service: JobService = Depends(get_job_service),
):
    return service.get_all(status=status)


@router.post("/api/jobs")
def create_job(payload: dict, service: JobService = Depends(get_job_service)):
    try:
        return service.create(payload)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/api/jobs/{job_id}")
def get_job(job_id: int, service: JobService = Depends(get_job_service)):
    try:
        return service.get_by_id(job_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.patch("/api/jobs/{job_id}")
def update_job(job_id: int, payload: dict, service: JobService = Depends(get_job_service)):
    try:
        return service.update(job_id, payload)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.get("/api/jobs/{job_id}/callback-history")
def callback_history(job_id: int, service: JobService = Depends(get_job_service)):
    try:
        return service.callback_history(job_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.post("/api/invoices")
def create_invoice(payload: dict, service: InvoiceService = Depends(get_invoice_service)):
    try:
        return service.create(payload)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/api/invoices/{invoice_id}")
def get_invoice(invoice_id: int, service: InvoiceService = Depends(get_invoice_service)):
    try:
        return service.get_by_id(invoice_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.post("/api/invoices/{invoice_id}/mark-paid")
def mark_paid(invoice_id: int, service: InvoiceService = Depends(get_invoice_service)):
    try:
        return service.mark_paid(invoice_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
