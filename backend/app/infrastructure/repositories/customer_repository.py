from __future__ import annotations

from typing import Sequence

from sqlmodel import Session, select

from ...domain.customer import Customer
from ...models import Customer as CustomerORM


class CustomerRepository:
    def __init__(self, session: Session):
        self.session = session

    def list_customers(self) -> Sequence[Customer]:
        rows = self.session.exec(select(CustomerORM).order_by(CustomerORM.name)).all()
        return [
            Customer(
                id=row.id,
                name=row.name,
                phone=row.phone,
                email=row.email,
                address=row.address,
                created_at=row.created_at,
            )
            for row in rows
        ]

    def get_customer(self, customer_id: int) -> Customer:
        row = self.session.get(CustomerORM, customer_id)
        if not row:
            raise ValueError("Customer not found")
        return Customer(
            id=row.id,
            name=row.name,
            phone=row.phone,
            email=row.email,
            address=row.address,
            created_at=row.created_at,
        )

    def create_customer(self, customer: Customer) -> Customer:
        row = CustomerORM(**customer.__dict__)
        self.session.add(row)
        self.session.commit()
        self.session.refresh(row)
        return Customer(
            id=row.id,
            name=row.name,
            phone=row.phone,
            email=row.email,
            address=row.address,
            created_at=row.created_at,
        )
