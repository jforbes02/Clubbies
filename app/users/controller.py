from fastapi import APIRouter, status
from app.core.database import DbSession
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
    return service.get_user_by_id(db, current_user.get_id())


# noinspection PyTypeHints
@router.put("/change-password", status_code=status.HTTP_200_OK)
def change_password(password_change: user_model.PasswordChange
                    ,db: DbSession
                    ,current_user: CurrentUser):
    service.change_password(db, current_user.get_id(), password_change)