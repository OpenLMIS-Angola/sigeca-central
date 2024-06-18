import jwt
import os

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from passlib.context import CryptContext
from typing import Annotated, Optional
from pydantic import ValidationError
from datetime import timezone, timedelta
from jwt.exceptions import InvalidTokenError, InvalidSignatureError
from datetime import datetime

from models import TokenPayload
from db import fetch_user_for_auth, User

SECRET_KEY = os.getenv("API_AUTH_SECRET_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


def authenticate_user(username, password) -> Optional[User]:
    user = fetch_user_for_auth(username)
    if not user or not verify_password(password, user.password_hash):
        return None
    return user


def create_token(user: User) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    encoded_jwt = jwt.encode(TokenPayload(sub=user.username, exp=expire).dict(), SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def get_user(token: Annotated[str, Depends(oauth2_scheme)]) -> Optional[User]:
    try:
        payload = TokenPayload(**jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM]))
    except (InvalidSignatureError, InvalidTokenError, ValidationError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    user = fetch_user_for_auth(payload.sub)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid user",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user
