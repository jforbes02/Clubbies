from typing import Annotated
from fastapi import APIRouter, Depends, Request
from starlette import status
from . import reg_model
from . import service
from fastapi.security import OAuth2PasswordRequestForm
from ..core.database import DbSession
from ..protection.rate_limiting import limiter
import logging

router = APIRouter(
    prefix="/auth",
    tags=["auth"]
)


# noinspection PyTypeHints
@router.post("/register", status_code=status.HTTP_201_CREATED, response_model=reg_model.Token)
@limiter.limit("5/hour")
async def register_user(request: Request, create_user_request:reg_model.CreateUser, db:DbSession):
    return service.register_user(db, create_user_request)


# noinspection PyTypeHints
@router.post("/login", response_model=reg_model.Token)
async def login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()], db: DbSession):
    return service.login_for_access_token(form_data, db)


# noinspection PyTypeHints
@router.post("/refresh", response_model=reg_model.Token)
async def refresh_access_token(refresh_request: reg_model.RefreshTokenRequest):
    """
    Refresh access token using a valid refresh token.
    Returns new access token and refresh token.
    """
    try:
        # Verify the refresh token and get user data
        payload = service.verify_refresh_token(refresh_request.refresh_token)

        # Generate new access token
        new_access_token = service.create_access_token(
            username=payload["username"],
            user_id=int(payload["user_id"]),
            expires_delta=service.timedelta(minutes=service.ACCESS_TOKEN_EXPIRE_MINUTES)
        )

        # Generate new refresh token (token rotation for security)
        new_refresh_token = service.create_refresh_token(
            username=payload["username"],
            user_id=int(payload["user_id"])
        )

        logging.info(f"Successfully refreshed tokens for user {payload['username']}")

        return reg_model.Token(
            access_token=new_access_token,
            refresh_token=new_refresh_token,
            token_type="bearer"
        )
    except Exception as e:
        logging.error(f"Token refresh failed: {e}")
        raise

