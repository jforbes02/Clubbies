from sqlalchemy.orm import Session
from fastapi import HTTPException
from . import user_model
from app.models.models import User
from app.auth.service import verify_password, get_password_hash
import logging

def get_user_by_id(db: Session, user_id: int) -> User:
    user = db.query(User).get(user_id)
    if not user:
        logging.warning(f"User {user_id} not found")
    logging.info(f"User with ID {user_id} found")
    return user

def change_password(db:Session, user_id: int, password_change: user_model.PasswordChange) -> None:
    try:
        user = get_user_by_id(db, user_id) #get user id

        #verify current password
        if not verify_password(password_change.old_password, user.password_hashed):
            logging.warning(f"Invalid password for user {user_id}")
            raise HTTPException(status_code=401, detail="Invalid password")

        #verify new passwords are the same
        if password_change.new_password != user.new_password_confirmed:
            logging.warning(f"Passwords are not the same for password change for user {user_id}")
            raise HTTPException(status_code=401, detail="Passwords are not the same")

        #password update
        user.password_hashed = get_password_hash(password_change.new_password)
        db.commit()
        logging.info(f"Password change for user {user_id} has been updated")
    except Exception as e:
        logging.error("Failed to update password of user", exc_info=e)
        raise
    