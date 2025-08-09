from pydantic import BaseModel, EmailStr
from datetime import datetime


#model for getting user information
class UserResponse(BaseModel):
    user_id: int
    username: str
    email: EmailStr
    age: int

#allows changing passwords
class PasswordChange(BaseModel):
    old_password: str
    new_password: str
    new_password_confirmed: str