from pydantic import BaseModel, EmailStr, Field


#used for registration
class CreateUser(BaseModel):
    username: str = Field(..., min_length=4, max_length=40)
    email: EmailStr = Field(...)
    password: str = Field(..., min_length=6, description="Must be at least 6 characters long")
    age: int = Field(..., ge=18)


#returns token for authentication
class Token(BaseModel):
    access_token: str
    token_type: str


#JWT Payload - What's stored inside the JWT token
#what the user gets after authentication
class TokenData(BaseModel):
    user_id: str | None = None

    def get_id(self) -> int | None:
        """
        Return the user id as a UUID or None
        """
        if self.user_id:
            return int(self.user_id)
        return None