#what data is accepted and what do my tables look like
from sqlalchemy import Column, Integer, String, DateTime, Float, CheckConstraint, Text, ForeignKey
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.orm import relationship

from database import Base
from typing import Optional


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


class Venue(Base):
    __tablename__ = "venues"
    venue_id = Column(Integer, primary_key=True, index=True)
    venue_name = Column(String(255), nullable=False)
    address = Column(String(255), nullable=False)
    hours = Column(String(255), nullable=False)
    venue_type = Column(String(35), nullable=False) #lounge, bar, jazz club, club,
    age_req = Column(Integer, nullable=False)
    description = Column(String(255))
    capacity = Column(String(20))

    #relationships
    reviews = relationship("Review", backref="venue")
    photos = relationship("Photo", backref="venue")

#TempEvent in future expansion

#Pydantic MODELS

#Pydantic model for creating users
#used for registration
class CreateUser(BaseModel):
    username: str = Field(..., min_length=4, max_length=40)
    email: EmailStr = Field(...)
    password: str = Field(..., min_length=6, description="Must be at least 6 characters long")
    age: int = Field(...)

#Pydantic model for getting user information
class UserResponse(BaseModel):
    user_id: int
    username: str
    email: EmailStr
    age: int

class CreatePhoto(BaseModel):
    img_data: str = Field(...)
    caption: Optional[str] = None