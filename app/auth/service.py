from datetime import timedelta, datetime
from typing import Annotated
from fastapi import HTTPException, Depends
from passlib.context import CryptContext
import jwt
from jwt import PyJWTError
from sqlalchemy.orm import Session
from app.models.models import User
from . import reg_model
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
import logging
import os
from dotenv import load_dotenv
#config
load_dotenv()
SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 10

#security setup
oauth2_bearer = OAuth2PasswordBearer(tokenUrl="auth/login")
bcrypt = CryptContext(schemes=["bcrypt"], deprecated="auto")

#Passwording Functions (hash and verification)
def verify_password(plain_password, hashed_password):
    return bcrypt.verify(plain_password, hashed_password)
def get_password_hash(password: str) -> str:
    return bcrypt.hash(password)

#Authentication functions

# noinspection PyTypeChecker
def authenticate_user(username: str, password: str, db: Session) -> User | bool:
    """
    Checks if the username and password are valid
    returns Object if valid, false if not
    """
    # Try to find user by email first (since frontend sends email as username)
    user = db.query(User).filter(User.username == username).first()

    if not user or not verify_password(password, user.password_hashed): #check if exists and password matches
        logging.warning(f"Failed authentication attempt for user {username}")
        return False
    logging.info(f"Successful authentication attempt for user {username}")
    return user

def create_access_token(username: str, user_id: int, expires_delta: timedelta) -> str:
    """
    Creates JWT token that contains User info, expires after a specific time delta
    """
    encode = {
        'sub': username,
        'id': str(user_id), #converts UUID into a string for JSON
        'exp': datetime.utcnow() + expires_delta, #expiration time
    }
    return jwt.encode(encode, SECRET_KEY, algorithm=ALGORITHM) #makes and returns signed JWT

def verify_token(token: str) -> reg_model.TokenData:
    """
    Decodes and verifys JWT tokens
    :returns TokenData with user info if valid, AuthError if not
    """
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM]) #Decodes JWT
        user_id: str = payload.get("id")#gets user ID from ^^^
        return reg_model.TokenData(user_id=user_id) #Returns token Data
    except PyJWTError as e:
        logging.warning(f"Failed authentication attempt - invalid token provided")
        raise HTTPException(status_code=401, detail='Could not validate tokens') from e

#user Registration
def register_user(db: Session, create_user: reg_model.CreateUser) -> reg_model.Token:
    """
    Registers a new user and hashes the password before storing
    Returns an access token for immediate authentication
    """
    existing_user = db.query(User).filter((User.username == create_user.username) | (User.email == create_user.email)).first()
    if existing_user:
        logging.info(f"User already exists")
        if existing_user.username == create_user.username:
            raise HTTPException(status_code=400, detail="Username already exists")
        elif existing_user.email == create_user.email:
            raise HTTPException(status_code=400, detail="Email already exists")

    try:
        create_user_model = User(
            username=create_user.username,
            email=create_user.email,  # email from input
            age=create_user.age, #age from input
            password_hashed=get_password_hash(create_user.password) #hashes input
        )
        db.add(create_user_model) #adds to db session
        db.commit() #saves to db
        db.refresh(create_user_model) #refresh to get user_id
        logging.info(f"Created new user {create_user.username} Success!")

        # Create and return access token for immediate authentication
        token = create_access_token(create_user_model.username, create_user_model.user_id, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
        return reg_model.Token(access_token=token, token_type="bearer")
    except Exception as e:
        db.rollback()
        logging.error(f"Failed to register user: {create_user.username}. Error: {e}")
        raise HTTPException(status_code=500, detail="Failed to register user")

#Dependency functions for endpoints
def get_user(token: Annotated[str, Depends(oauth2_bearer)]) -> reg_model.TokenData:
    """
    extracts and verifies JWT token
    :returns user id from token
    """
    return verify_token(token)

CurrentUser = Annotated[reg_model.TokenData, Depends(get_user)]

def login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
            db:Session) -> reg_model.Token:
    user = authenticate_user(form_data.username, form_data.password, db)
    if not user:
        raise HTTPException(status_code=401, detail='Incorrect username or password')
    token = create_access_token(user.username, user.user_id, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    return reg_model.Token(access_token=token, token_type="bearer")

def require_admin(current_user: CurrentUser, db: Session):
    """
    Dependency to ensure the current user is an admin
    """
    user = db.query(User).filter(User.user_id == int(current_user.user_id)).first()
    if not user or user.role != 'admin':
        logging.warning(f"Unauthorized admin access attempt by user ID {current_user.user_id}")
        raise HTTPException(status_code=403, detail="Admin privileges required")
    return True