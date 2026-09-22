from __future__ import annotations

from typing import Sequence

from ..domain.job import Job, JobStatus
from ..infrastructure.repositories.job_repository import JobRepository


class JobService:
    def __init__(self, job_repository: JobRepository):
        self.job_repository = job_repository

    def get_all(self, status: JobStatus | None = None, customer_id: int | None = None) -> Sequence[Job]:
        return self.job_repository.list_jobs(status=status, customer_id=customer_id)

    def get_by_id(self, job_id: int) -> Job:
        return self.job_repository.get_job(job_id)

    def create(self, payload: dict) -> Job:
        job = Job(
            id=None,
            customer_id=payload["customer_id"],
            appliance_type=payload["appliance_type"],
            brand=payload.get("brand"),
            model_number=payload.get("model_number"),
            serial_number=payload.get("serial_number"),
            symptom=payload["symptom"],
            diagnosis=payload.get("diagnosis"),
            status=JobStatus(payload.get("status", JobStatus.LEAD.value)),
            scheduled_at=payload.get("scheduled_at"),
            notes=payload.get("notes"),
            part_needed=payload.get("part_needed"),
            part_eta=payload.get("part_eta"),
            original_job_id=payload.get("original_job_id"),
        )
        return self.job_repository.create_job(job)

    def update(self, job_id: int, payload: dict) -> Job:
        existing = self.job_repository.get_job(job_id)
        for key, value in payload.items():
            if value is not None and hasattr(existing, key):
                setattr(existing, key, value)
        return self.job_repository.update_job(existing)

    def callback_history(self, job_id: int) -> Sequence[Job]:
        return self.job_repository.get_callback_history(job_id)
