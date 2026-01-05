from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class PhotoBase(BaseModel):
    caption: Optional[str] = Field(None, max_length=255)
    venue_id: int = Field(..., gt=0)

class PhotoResponse(BaseModel):
    photo_id: int
    img_url: str = Field(..., description="URL to access uploaded img")
    file_size: Optional[int] = Field(None, description="File size in bytes")
    venue_id: int = Field(..., gt=0)
    venue_name: str = Field(..., max_length=255)
    user_id: int
    username: str
    uploaded_at: datetime
    caption: Optional[str] = Field(None, max_length=255)
    content_type: str = Field(None, max_length=30)

    class Config:
        from_attributes = True
