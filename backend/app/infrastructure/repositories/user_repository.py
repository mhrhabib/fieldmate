from __future__ import annotations

from typing import Optional

from sqlmodel import Session, select

from ...domain.user import User
from ...models import UserAccount


class UserRepository:
    def __init__(self, session: Session):
        self.session = session

    def get_by_email(self, email: str) -> Optional[User]:
        row = self.session.exec(select(UserAccount).where(UserAccount.email == email)).first()
        return self._to_domain(row) if row else None

    def get_by_id(self, user_id: int) -> Optional[User]:
        row = self.session.get(UserAccount, user_id)
        return self._to_domain(row) if row else None

    def create(self, name: str, email: str, hashed_password: str) -> User:
        row = UserAccount(name=name, email=email, hashed_password=hashed_password)
        self.session.add(row)
        self.session.commit()
        self.session.refresh(row)
        return self._to_domain(row)

    @staticmethod
    def _to_domain(row: UserAccount) -> User:
        return User(
            id=row.id,
            name=row.name,
            email=row.email,
            hashed_password=row.hashed_password,
            created_at=row.created_at,
        )
