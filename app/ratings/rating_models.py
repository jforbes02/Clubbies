from pydantic import BaseModel, Field
from datetime import datetime


class CreateRating(BaseModel):
    venue_id: int = Field(..., description="ID of venue being rated")
    rating: float = Field(..., gt=0, le=5, description="Numeric rating from 0.1 - 5.0")


class UpdateRating(BaseModel):
    rating: float = Field(..., gt=0, le=5, description="Updated numeric rating")


class RatingResponse(BaseModel):
    rating_id: int
    rating: float
    created_at: datetime
    user_id: int
    venue_id: int

    class Config:
        from_attributes = True
