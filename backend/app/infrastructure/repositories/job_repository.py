from __future__ import annotations

from typing import Sequence

from sqlmodel import Session, select

from ...domain.job import Job, JobStatus
from ...models import Job as JobORM


class JobRepository:
    def __init__(self, session: Session):
        self.session = session

    def list_jobs(self, status: JobStatus | None = None, customer_id: int | None = None) -> Sequence[Job]:
        query = select(JobORM)
        if status is not None:
            query = query.where(JobORM.status == status.value)
        if customer_id is not None:
            query = query.where(JobORM.customer_id == customer_id)
        query = query.order_by(JobORM.created_at.desc())
        rows = self.session.exec(query).all()
        return [
            Job(
                id=row.id,
                customer_id=row.customer_id,
                appliance_type=row.appliance_type,
                brand=row.brand,
                model_number=row.model_number,
                serial_number=row.serial_number,
                symptom=row.symptom,
                diagnosis=row.diagnosis,
                status=JobStatus(row.status),
                scheduled_at=row.scheduled_at,
                notes=row.notes,
                part_needed=row.part_needed,
                part_eta=row.part_eta,
                original_job_id=row.original_job_id,
                created_at=row.created_at,
                updated_at=row.updated_at,
            )
            for row in rows
        ]

    def get_job(self, job_id: int) -> Job:
        row = self.session.get(JobORM, job_id)
        if not row:
            raise ValueError("Job not found")
        return Job(
            id=row.id,
            customer_id=row.customer_id,
            appliance_type=row.appliance_type,
            brand=row.brand,
            model_number=row.model_number,
            serial_number=row.serial_number,
            symptom=row.symptom,
            diagnosis=row.diagnosis,
            status=JobStatus(row.status),
            scheduled_at=row.scheduled_at,
            notes=row.notes,
            part_needed=row.part_needed,
            part_eta=row.part_eta,
            original_job_id=row.original_job_id,
            created_at=row.created_at,
            updated_at=row.updated_at,
        )

    def create_job(self, job: Job) -> Job:
        row = JobORM(**job.__dict__)
        self.session.add(row)
        self.session.commit()
        self.session.refresh(row)
        return self.get_job(row.id)

    def update_job(self, job: Job) -> Job:
        row = self.session.get(JobORM, job.id)
        if not row:
            raise ValueError("Job not found")
        for field, value in job.__dict__.items():
            if field.startswith("_"):
                continue
            setattr(row, field, value)
        self.session.add(row)
        self.session.commit()
        self.session.refresh(row)
        return self.get_job(row.id)

    def get_callback_history(self, job_id: int) -> Sequence[Job]:
        root_id = self.get_job(job_id).original_job_id or job_id
        rows = self.session.exec(
            select(JobORM).where((JobORM.id == root_id) | (JobORM.original_job_id == root_id))
        ).all()
        return [
            Job(
                id=row.id,
                customer_id=row.customer_id,
                appliance_type=row.appliance_type,
                brand=row.brand,
                model_number=row.model_number,
                serial_number=row.serial_number,
                symptom=row.symptom,
                diagnosis=row.diagnosis,
                status=JobStatus(row.status),
                scheduled_at=row.scheduled_at,
                notes=row.notes,
                part_needed=row.part_needed,
                part_eta=row.part_eta,
                original_job_id=row.original_job_id,
                created_at=row.created_at,
                updated_at=row.updated_at,
            )
            for row in rows
        ]
