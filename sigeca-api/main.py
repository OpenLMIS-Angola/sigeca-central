import os
import logging

from logging import config as log_config
from fastapi import FastAPI, Depends, Response, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from typing import Annotated

from db import fetch_all_facilities, execute_sync_input
from auth import authenticate_user, create_token, get_user
from models import TokenResponse, SyncInput, MSFacility, User

app = FastAPI(root_path=os.getenv("ROOT_PATH"))


@app.post("/token/")
async def login(form_data: Annotated[OAuth2PasswordRequestForm, Depends()], ) -> TokenResponse:
    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return TokenResponse(access_token=create_token(user), token_type="bearer")


@app.get("/facilities/")
async def get_facilities(user: Annotated[User, Depends(get_user)]) -> list[MSFacility]:
    return fetch_all_facilities()


@app.post("/sync/")
async def sync_data(user: Annotated[User, Depends(get_user)],
                    data: list[SyncInput]) -> Response:
    execute_sync_input(data)
    return Response(content="", status_code=200)
