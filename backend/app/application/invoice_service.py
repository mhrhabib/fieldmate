from __future__ import annotations

from ..domain.invoice import Invoice, InvoiceLineItem, InvoiceStatus
from ..infrastructure.repositories.invoice_repository import InvoiceRepository


class InvoiceService:
    def __init__(self, invoice_repository: InvoiceRepository):
        self.invoice_repository = invoice_repository

    def create(self, payload: dict) -> Invoice:
        line_items = [
            InvoiceLineItem(
                description=item["description"],
                kind=item["kind"],
                quantity=float(item.get("quantity", 1)),
                unit_price=float(item["unit_price"]),
            )
            for item in payload["line_items"]
        ]
        invoice = Invoice(
            id=None,
            job_id=payload["job_id"],
            status=InvoiceStatus.UNPAID,
            line_items=line_items,
        )
        return self.invoice_repository.create_invoice(invoice)

    def get_by_id(self, invoice_id: int) -> Invoice:
        return self.invoice_repository.get_invoice(invoice_id)

    def mark_paid(self, invoice_id: int) -> Invoice:
        return self.invoice_repository.mark_paid(invoice_id)
