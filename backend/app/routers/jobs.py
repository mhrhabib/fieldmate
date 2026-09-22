from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select

from ..database import get_session
from ..models import Customer, Job, JobCreate, JobRead, JobStatus, JobUpdate

router = APIRouter(prefix="/api/jobs", tags=["jobs"])


@router.get("/", response_model=list[JobRead])
def list_jobs(
    status: JobStatus | None = None,
    customer_id: int | None = None,
    session: Session = Depends(get_session),
):
    """List jobs, optionally filtered by status (e.g. ?status=waiting_on_part
    for the 'what's blocked on parts' view) or by customer."""
    query = select(Job)
    if status:
        query = query.where(Job.status == status)
    if customer_id:
        query = query.where(Job.customer_id == customer_id)
    query = query.order_by(Job.created_at.desc())
    return session.exec(query).all()


@router.post("/", response_model=JobRead, status_code=201)
def create_job(payload: JobCreate, session: Session = Depends(get_session)):
    if not session.get(Customer, payload.customer_id):
        raise HTTPException(404, "Customer not found")
    job = Job.model_validate(payload)
    session.add(job)
    session.commit()
    session.refresh(job)
    return job


@router.get("/{job_id}", response_model=JobRead)
def get_job(job_id: int, session: Session = Depends(get_session)):
    job = session.get(Job, job_id)
    if not job:
        raise HTTPException(404, "Job not found")
    return job


@router.patch("/{job_id}", response_model=JobRead)
def update_job(job_id: int, payload: JobUpdate, session: Session = Depends(get_session)):
    """Partial update — this is what the app calls when a tech moves a job
    from 'in_progress' to 'waiting_on_part' and fills in part_needed, or
    marks it 'completed'."""
    job = session.get(Job, job_id)
    if not job:
        raise HTTPException(404, "Job not found")

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(job, field, value)
    job.updated_at = datetime.now(timezone.utc)

    session.add(job)
    session.commit()
    session.refresh(job)
    return job


@router.get("/{job_id}/callback-history", response_model=list[JobRead])
def callback_history(job_id: int, session: Session = Depends(get_session)):
    """Walk the original_job_id chain to show every visit tied to the same
    underlying issue — this is the first-time-fix-rate data no generic FSM
    tool captures."""
    job = session.get(Job, job_id)
    if not job:
        raise HTTPException(404, "Job not found")

    root_id = job.original_job_id or job.id
    chain = session.exec(
        select(Job).where((Job.id == root_id) | (Job.original_job_id == root_id))
    ).all()
    return chain
