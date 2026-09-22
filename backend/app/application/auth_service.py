from __future__ import annotations

import hashlib
import hmac
import os
import secrets
from datetime import datetime, timedelta, timezone

import jwt

from ..domain.user import User
from ..infrastructure.repositories.user_repository import UserRepository

# In production, set AUTH_SECRET_KEY to a long random value via the environment.
# The fallback below is only for local dev so the app runs out of the box.
AUTH_SECRET_KEY = os.getenv("AUTH_SECRET_KEY", "dev-only-insecure-secret-change-me")
JWT_ALGORITHM = "HS256"
TOKEN_TTL = timedelta(days=7)

_PBKDF2_ITERATIONS = 260_000


def _hash_password(password: str, salt: str | None = None) -> str:
    salt = salt or secrets.token_hex(16)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt.encode("utf-8"), _PBKDF2_ITERATIONS)
    return f"{salt}${digest.hex()}"


def _verify_password(password: str, stored_hash: str) -> bool:
    try:
        salt, _ = stored_hash.split("$", 1)
    except ValueError:
        return False
    candidate = _hash_password(password, salt=salt)
    return hmac.compare_digest(candidate, stored_hash)


class AuthError(ValueError):
    """Raised for bad credentials or invalid/expired tokens."""


class AuthService:
    def __init__(self, user_repository: UserRepository):
        self.user_repository = user_repository

    def signup(self, payload: dict) -> tuple[User, str]:
        name = (payload.get("name") or "").strip()
        email = (payload.get("email") or "").strip().lower()
        password = payload.get("password") or ""

        if not name:
            raise AuthError("Name is required")
        if "@" not in email:
            raise AuthError("A valid email is required")
        if len(password) < 8:
            raise AuthError("Password must be at least 8 characters")
        if self.user_repository.get_by_email(email):
            raise AuthError("An account with this email already exists")

        user = self.user_repository.create(name=name, email=email, hashed_password=_hash_password(password))
        return user, self._issue_token(user)

    def login(self, payload: dict) -> tuple[User, str]:
        email = (payload.get("email") or "").strip().lower()
        password = payload.get("password") or ""

        user = self.user_repository.get_by_email(email)
        if not user or not _verify_password(password, user.hashed_password):
            raise AuthError("Invalid email or password")

        return user, self._issue_token(user)

    def current_user(self, token: str) -> User:
        try:
            claims = jwt.decode(token, AUTH_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        except jwt.PyJWTError as exc:
            raise AuthError("Invalid or expired session") from exc

        user = self.user_repository.get_by_id(int(claims["sub"]))
        if not user:
            raise AuthError("Invalid or expired session")
        return user

    def _issue_token(self, user: User) -> str:
        now = datetime.now(timezone.utc)
        claims = {"sub": str(user.id), "iat": now, "exp": now + TOKEN_TTL}
        return jwt.encode(claims, AUTH_SECRET_KEY, algorithm=JWT_ALGORITHM)
