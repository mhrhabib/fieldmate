from __future__ import annotations

from sqlmodel import Session

from ...domain.invoice import Invoice, InvoiceLineItem, InvoiceStatus
from ...models import Invoice as InvoiceORM, InvoiceLineItem as InvoiceLineItemORM


class InvoiceRepository:
    def __init__(self, session: Session):
        self.session = session

    def create_invoice(self, invoice: Invoice) -> Invoice:
        row = InvoiceORM(job_id=invoice.job_id, status=invoice.status.value)
        self.session.add(row)
        self.session.flush()
        for item in invoice.line_items:
            self.session.add(
                InvoiceLineItemORM(
                    invoice_id=row.id,
                    description=item.description,
                    kind=item.kind,
                    quantity=item.quantity,
                    unit_price=item.unit_price,
                )
            )
        self.session.commit()
        self.session.refresh(row)
        return Invoice(
            id=row.id,
            job_id=row.job_id,
            status=InvoiceStatus(row.status),
            line_items=[
                InvoiceLineItem(
                    description=item.description,
                    kind=item.kind,
                    quantity=item.quantity,
                    unit_price=item.unit_price,
                )
                for item in row.line_items
            ],
            created_at=row.created_at,
        )

    def get_invoice(self, invoice_id: int) -> Invoice:
        row = self.session.get(InvoiceORM, invoice_id)
        if not row:
            raise ValueError("Invoice not found")
        return Invoice(
            id=row.id,
            job_id=row.job_id,
            status=InvoiceStatus(row.status),
            line_items=[
                InvoiceLineItem(
                    description=item.description,
                    kind=item.kind,
                    quantity=item.quantity,
                    unit_price=item.unit_price,
                )
                for item in row.line_items
            ],
            created_at=row.created_at,
        )

    def mark_paid(self, invoice_id: int) -> Invoice:
        row = self.session.get(InvoiceORM, invoice_id)
        if not row:
            raise ValueError("Invoice not found")
        row.status = InvoiceStatus.PAID.value
        self.session.add(row)
        self.session.commit()
        self.session.refresh(row)
        return self.get_invoice(row.id)
