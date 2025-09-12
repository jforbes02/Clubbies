from sqlalchemy.orm import Session
from fastapi import HTTPException
from . import user_model
from app.models.models import User
from app.auth.service import verify_password, get_password_hash, CurrentUser
import logging
from typing import List


def get_user_by_id(db: Session, user_id: int) -> User:
    """Internal function for getting user by ID - used by other services"""
    user = db.query(User).get(user_id)
    if not user:
        logging.warning(f"User {user_id} not found")
        raise HTTPException(status_code=404, detail="User not found")
    logging.info(f"User with ID {user_id} found")
    return user

def get_current_user_profile(db: Session, current_user: CurrentUser) -> User:
    """Get current user's profile - for public API"""
    user_id = current_user.get_id()
    user = db.query(User).get(user_id)
    if not user:
        logging.warning(f"Current user {user_id} not found")
        raise HTTPException(status_code=404, detail="User not found")
    logging.info(f"Retrieved profile for user {user_id}")
    return user


def change_password(db:Session, user_id: int, password_change: user_model.PasswordChange) -> None:
    try:
        user = get_user_by_id(db, user_id) #get user id

        #verify current password
        if not verify_password(password_change.old_password, user.password_hashed):
            logging.warning(f"Invalid password for user {user_id}")
            raise HTTPException(status_code=401, detail="Invalid password")

        #verify new passwords are the same
        if password_change.new_password != password_change.new_password_confirmed:
            logging.warning(f"Passwords are not the same for password change for user {user_id}")
            raise HTTPException(status_code=400, detail="Passwords are not the same")

        #password update
        user.password_hashed = get_password_hash(password_change.new_password)
        db.commit()
        logging.info(f"Password change for user {user_id} has been updated")
    except HTTPException:
        raise  # Re-raise the original HTTPException
    except Exception as e:
        db.rollback()
        logging.error(f"Failed to update password for user {user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to update password")

def search_users(db: Session, username: str, limit: int = 10):
    """Search users by username - returns limited public info"""
    try:
        users = db.query(User.user_id, User.username).filter(
            User.username.ilike(f"%{username}%")
        ).limit(limit).all()
        logging.info(f"Found {len(users)} users matching '{username}'")
        return users
    except Exception as e:
        logging.error(f"Error searching users: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to search users")

def delete_user(db: Session, user_id: int):
    try:
        user = get_user_by_id(db, user_id)
        db.delete(user)
        db.commit()
        logging.info(f"User {user_id} has been deleted")
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logging.error(f"Failed to delete user {user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to delete user")