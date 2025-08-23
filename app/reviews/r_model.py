from pydantic import BaseModel, Field, field_validator
from typing import Optional
from datetime import datetime


# noinspection PyNestedDecorators
class CreateReview(BaseModel):
    venue_id: int = Field(..., description="ID of reviewed venue")
    review_text: Optional[str] = Field(None, max_length=1000, description="Optional Review Text")
    rating: float = Field(..., gt=0, le=5, description="Numeric rating from .1 - 5.0")

    #ensures reviews are not empty
    @field_validator("review_text")
    @classmethod
    def validate_review_text(cls, v):
        if v is not None and not v.strip():
            raise ValueError("Review text cannot be empty")
        return v.strip() if v else v

#returns data of reviews (output)
class ReviewResponse(BaseModel):
    review_id: int
    rating: float
    created_at: datetime
    user_id: int
    venue_id: int
    review_text: Optional[str]
    username: str
    venue_name: str

    class Config:
        from_attributes = True
#updating reviews input
# noinspection PyNestedDecorators
class UpdateReview(BaseModel):
    rating: Optional[float] = Field(None, gt=0, le=5, description="Updated numeric rating")
    review_text: Optional[str] = Field(None, max_length=1000, description="Updated review text")


    #enssures reviews are not empty
    @field_validator("review_text")
    @classmethod
    def validate_review_text(cls, v):
        if v is not None and not v.strip():
            raise ValueError("Review text cannot be empty")
        return v.strip() if v else v