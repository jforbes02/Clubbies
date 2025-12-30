from pydantic import BaseModel, EmailStr


#model for getting user information
class UserResponse(BaseModel):
    user_id: int
    username: str
    email: EmailStr
    age: int
    role: str

#allows changing passwords
class PasswordChange(BaseModel):
    old_password: str
    new_password: str
    new_password_confirmed: str

#model for user search results (limited public info)
class UserSearchResponse(BaseModel):
    user_id: int
    username: str

#model for updating user role (admin only)
class RoleUpdate(BaseModel):
    role: str