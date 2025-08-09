from typing import Annotated
from fastapi import APIRouter, Depends, Request
from starlette import status
from . import reg_model
from . import service
from fastapi.security import OAuth2PasswordRequestForm
from ..core.database import DbSession
from ..protection.rate_limiting import limiter


router = APIRouter(
    prefix="/auth",
    tags=["auth"]
)

@router.post("/", status_code=status.HTTP_201_CREATED)
@limiter.limit("5/hour")
async def register_user(request: Request, db:DbSession, create_user_request:reg_model.CreateUser):
    service.register_user(db, create_user_request)

@router.post("/token", response_model=reg_model.Token)
async def login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()], db: DbSession):
    return service.login_for_access_token(form_data, db)