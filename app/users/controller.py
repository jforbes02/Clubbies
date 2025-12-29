from fastapi import APIRouter, status, HTTPException
from app.core.database import DbSession
from app.models.models import User
from . import user_model
from . import service
from ..auth.service import CurrentUser, require_admin

router = APIRouter(
    prefix="/users",
    tags=["users"],
)


# noinspection PyTypeHints
@router.get("/me", response_model=user_model.UserResponse)
def get_current_user(db: DbSession, current_user: CurrentUser):
    """Get the current user's profile"""
    current_user_id = current_user.get_id()
    user = service.get_user_by_id(db, current_user_id)
    return user_model.UserResponse(
        user_id=user.user_id,
        username=user.username,
        email=user.email,
        age=user.age,
        role=user.role
    )


# noinspection PyTypeHints
@router.get("/{user_id}", response_model=user_model.UserResponse)
def get_user_profile(user_id: int, db: DbSession, current_user: CurrentUser):
    """Get any user's public profile (requires authentication)"""
    user = service.get_user_by_id(db, user_id)
    return user_model.UserResponse(
        user_id=user.user_id,
        username=user.username,
        email=user.email,
        age=user.age,
        role=user.role
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

@router.get("/search/", response_model=list[user_model.UserSearchResponse])
def search_users(username: str, db: DbSession, limit: int = 10):
    """Search for users by username (public endpoint, no auth required)"""
    users = service.search_users(db, username, limit)
    return [user_model.UserSearchResponse(
        user_id=user.user_id,
        username=user.username
    ) for user in users]


# Admin endpoints
@router.get("/admin/all", response_model=list[user_model.UserResponse])
def get_all_users(db: DbSession, current_user: CurrentUser, limit: int = 100):
    """Get all users (admin only)"""
    require_admin(current_user, db)
    users = db.query(User).limit(limit).all()
    return [user_model.UserResponse(
        user_id=user.user_id,
        username=user.username,
        email=user.email,
        age=user.age,
        role=user.role
    ) for user in users]


@router.delete("/admin/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_user_admin(user_id: int, db: DbSession, current_user: CurrentUser):
    """Delete a user by ID (admin only)"""
    require_admin(current_user, db)

    # Prevent admin from deleting themselves
    if user_id == current_user.get_id():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete your own account"
        )

    service.delete_user(db, user_id)


@router.put("/admin/{user_id}/role", status_code=status.HTTP_200_OK)
def update_user_role(user_id: int, role_data: user_model.RoleUpdate, db: DbSession, current_user: CurrentUser):
    """Update a user's role (admin only)"""
    require_admin(current_user, db)

    # Prevent admin from changing their own role
    if user_id == current_user.get_id():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot change your own role"
        )

    user = service.get_user_by_id(db, user_id)
    user.role = role_data.role
    db.commit()

    return {"message": "User role updated successfully"}