from __future__ import annotations

from fastapi import APIRouter, Depends, Header, HTTPException, Query
from sqlmodel import Session

from ..application.auth_service import AuthError, AuthService
from ..application.customer_service import CustomerService
from ..application.invoice_service import InvoiceService
from ..application.job_service import JobService
from ..database import get_session
from ..domain.user import User
from ..infrastructure.repositories.customer_repository import CustomerRepository
from ..infrastructure.repositories.invoice_repository import InvoiceRepository
from ..infrastructure.repositories.job_repository import JobRepository
from ..infrastructure.repositories.user_repository import UserRepository
from ..domain.job import JobStatus

router = APIRouter()


def get_auth_service(session: Session = Depends(get_session)) -> AuthService:
    return AuthService(UserRepository(session))


def get_current_user(
    authorization: str | None = Header(default=None),
    auth_service: AuthService = Depends(get_auth_service),
) -> User:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(401, "Missing or invalid Authorization header")
    token = authorization.split(" ", 1)[1]
    try:
        return auth_service.current_user(token)
    except AuthError as exc:
        raise HTTPException(401, str(exc)) from exc


def get_customer_service(session: Session = Depends(get_session)) -> CustomerService:
    return CustomerService(CustomerRepository(session))


def get_job_service(session: Session = Depends(get_session)) -> JobService:
    return JobService(JobRepository(session))


def get_invoice_service(session: Session = Depends(get_session)) -> InvoiceService:
    return InvoiceService(InvoiceRepository(session))


@router.get("/api/health")
def health() -> dict:
    return {"status": "ok"}


def _user_out(user: User, token: str) -> dict:
    return {
        "token": token,
        "user": {"id": user.id, "name": user.name, "email": user.email},
    }


@router.post("/api/auth/signup", status_code=201)
def signup(payload: dict, service: AuthService = Depends(get_auth_service)):
    try:
        user, token = service.signup(payload)
    except AuthError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    return _user_out(user, token)


@router.post("/api/auth/login")
def login(payload: dict, service: AuthService = Depends(get_auth_service)):
    try:
        user, token = service.login(payload)
    except AuthError as exc:
        raise HTTPException(status_code=401, detail=str(exc)) from exc
    return _user_out(user, token)


@router.get("/api/auth/me")
def me(current_user: User = Depends(get_current_user)):
    return {"id": current_user.id, "name": current_user.name, "email": current_user.email}


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
