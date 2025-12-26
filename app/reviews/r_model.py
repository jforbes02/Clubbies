from pydantic import BaseModel, Field, field_validator
from typing import Optional
from datetime import datetime


# noinspection PyNestedDecorators
class CreateReview(BaseModel):
    venue_id: int = Field(..., description="ID of reviewed venue")
    review_text: str = Field(..., min_length=1, max_length=1000, description="Review Text")

    #ensures reviews are not empty
    @field_validator("review_text")
    @classmethod
    def validate_review_text(cls, v):
        if not v.strip():
            raise ValueError("Review text cannot be empty")
        return v.strip()

#returns data of reviews (output)
class ReviewResponse(BaseModel):
    review_id: int
    created_at: datetime
    user_id: int
    venue_id: int
    review_text: str
    username: str
    venue_name: str

    class Config:
        from_attributes = True
#updating reviews input
# noinspection PyNestedDecorators
class UpdateReview(BaseModel):
    review_text: str = Field(..., min_length=1, max_length=1000, description="Updated review text")

    #ensures reviews are not empty
    @field_validator("review_text")
    @classmethod
    def validate_review_text(cls, v):
        if not v.strip():
            raise ValueError("Review text cannot be empty")
        return v.strip()