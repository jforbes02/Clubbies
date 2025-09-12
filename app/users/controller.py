from fastapi import APIRouter, status, HTTPException
from app.core.database import DbSession
from app.models.models import User
from . import user_model
from . import service
from ..auth.service import CurrentUser

router = APIRouter(
    prefix="/users",
    tags=["users"],
)


# noinspection PyTypeHints
@router.get("/me", response_model=user_model.UserResponse)
def get_current_user(current_user: CurrentUser, db: DbSession):
    user = service.get_current_user_profile(db, current_user)
    return user_model.UserResponse(
        user_id=user.user_id,
        username=user.username,
        email=user.email,
        age=user.age
    )


# noinspection PyTypeHints
@router.put("/change-password", status_code=status.HTTP_200_OK)
def change_password(password_change: user_model.PasswordChange,
                    db: DbSession,
                    current_user: CurrentUser):
    service.change_password(db, current_user.get_id(), password_change)
    return {"message": "Password updated successfully"}

@router.delete("/delete", status_code=status.HTTP_204_NO_CONTENT)
def delete_user(db: DbSession, current_user: CurrentUser):
    service.delete_user(db, current_user.get_id())
