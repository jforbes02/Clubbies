#what data is accepted and what do my tables look like
from datetime import datetime
from enum import Enum
from sqlalchemy import Column, Integer, String, DateTime, Float, CheckConstraint, Text, ForeignKey, Enum as SQEnum
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import ARRAY
from app.core.database import Base
from typing import Optional, List


                        #SQALCHEMY MODELS
class User(Base):
    __tablename__ = "users"
    user_id = Column(Integer, primary_key=True, index=True)
    username = Column(String(40), unique=True, index=True, nullable=False)
    password_hashed = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    age = Column(Integer, nullable=False)


    #relationships
    #One user can make multiple reviews but each review belongs to one user
    reviews = relationship("Review", backref="user")
    #One user can post many photos but each photo belongs to one user
    photos = relationship("Photo", backref="user")

    #age restriction
    __table_args__ = (
        CheckConstraint('age >= 16'),
    )


class Photo(Base):
    __tablename__ = "photos"
    photo_id = Column(Integer, primary_key=True, index=True)
    img_data = Column(Text, nullable=False)
    caption = Column(String(255))
    uploaded_at = Column(DateTime, nullable=False)

    #relationships
    #each photo has a user with a user_id
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    #each photo posted has a venue with a venue id
    venue_id = Column(Integer, ForeignKey("venues.venue_id"), nullable=False)

class Review(Base):
    __tablename__ = "reviews"
    review_id = Column(Integer, primary_key=True, index=True)
    rating = Column(Float, nullable=False)
    review_text = Column(Text)
    date_made = Column(DateTime, nullable=False)

    __table_args__ = (
        CheckConstraint('rating <= 5'),
        CheckConstraint('rating > 0')
    )

    #relationships
    #each review is written by a user with a user id
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    #each review has a venue with a venue id
    venue_id = Column(Integer, ForeignKey("venues.venue_id"), nullable=False)

class VenueType(str, Enum):
    NIGHTCLUB = 'Nightclub'
    BAR = 'Bar'
    LOUNGE = 'Lounge'
    JAZZCLUB = 'Jazz_club'
    ROOFTOP = 'Rooftop'
    SPORTSBAR = 'Sports_bar'
    COLLEGE = 'College'

#venue space
class VenueCapacity(str, Enum):
    MASSIVE = 'Massive'
    LARGE = 'Large'
    MEDIUM = 'Medium'
    SMALL = 'Small'
    TINY = 'Tiny'


class Venue(Base):
    __tablename__ = "venues"
    venue_id = Column(Integer, primary_key=True, index=True)
    venue_name = Column(String(255), nullable=False)
    address = Column(String(255), nullable=False)
    hours = Column(String(100), nullable=False)
    venue_type = Column(ARRAY(SQEnum(VenueType)), nullable=False) #lounge, bar, jazz club, club,
    age_req = Column(Integer, nullable=False)
    description = Column(String(255))
    capacity = Column(SQEnum(VenueCapacity), nullable=False)

    #relationships
    reviews = relationship("Review", backref="venue")
    photos = relationship("Photo", backref="venue")

#TempEvent in future expansion

                    #Pydantic MODELS


                    #User Models


#model for getting user information
class UserResponse(BaseModel):
    user_id: int
    username: str
    email: EmailStr
    age: int

                        #Photo Models
class CreatePhoto(BaseModel):
    img_data: str = Field(..., description="The image data")
    caption: Optional[str] = Field(None, max_length=255)
    venue_id: int = Field(..., gt=0)

class PhotoResponse(BaseModel):
    img_data: str = Field(...)
    caption: Optional[str] = None
    venue_id: int
    user_id: int
    uploaded_at: datetime
    photo_id: int
    username: str
    venue_name: str

class UpdatePhoto(BaseModel):
    img_data: Optional[str] = None
    caption: Optional[str] = None


                        #Review Models

#model for creating new reviews (input)
class CreateReview(BaseModel):
    venue_id: int = Field(..., gt=0, description="ID of reviewed venue")
    review_text: Optional[str] = Field(None, max_length=1000, description="Optional Review Text")
    rating: float = Field(..., gt=0, le=5, description="Numeric rating from .1 - 5.0")

#returns data of reviews (output)
class ReviewResponse(BaseModel):
    review_id: int
    rating: float
    date_made: datetime
    user_id: int
    venue_id: int
    review_text: Optional[str]
    username: Optional[str] = None
    venue_name: Optional[str] = None

#updating reviews input
class UpdateReview(BaseModel):
    rating: Optional[float] = Field(None, gt=0, le=5, description="Updated numeric rating")
    review_text: Optional[str] = Field(None, max_length=1000, description="Updated review text")
