from __future__ import annotations

from typing import Sequence

from ..domain.customer import Customer
from ..infrastructure.repositories.customer_repository import CustomerRepository


class CustomerService:
    def __init__(self, customer_repository: CustomerRepository):
        self.customer_repository = customer_repository

    def get_all(self) -> Sequence[Customer]:
        return self.customer_repository.list_customers()

    def get_by_id(self, customer_id: int) -> Customer:
        return self.customer_repository.get_customer(customer_id)

    def create(self, payload: dict) -> Customer:
        customer = Customer(
            id=None,
            name=payload["name"],
            phone=payload["phone"],
            email=payload.get("email"),
            address=payload.get("address"),
        )
        return self.customer_repository.create_customer(customer)
