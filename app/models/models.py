from enum import Enum
from sqlalchemy import Column, Integer, String, DateTime, Float, CheckConstraint, Text, ForeignKey, Enum as SQEnum, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.sql import func
from app.core.database import Base


                        #SQALCHEMY MODELS
# noinspection SpellCheckingInspection
class User(Base):
    # noinspection SpellCheckingInspection
    __tablename__ = "users"
    user_id = Column(Integer, primary_key=True, index=True)
    username = Column(String(40), unique=True, index=True, nullable=False)
    password_hashed = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    age = Column(Integer, nullable=False)
    role = Column(SQEnum('user', 'admin', 'mod', name='user_role', create_type=False), default='user')
    

    #relationships
    #One user can make multiple reviews but each review belongs to one user
    reviews = relationship("Review", backref="user")
    #One user can post many photos but each photo belongs to one user
    photos = relationship("Photo", backref="user")
    #One user can have multiple ratings (one per venue)
    ratings = relationship("Rating", backref="user")

    #age restriction
    __table_args__ = (
        CheckConstraint('age >= 16'),
    )


class Photo(Base):
    __tablename__ = "photos"
    photo_id = Column(Integer, primary_key=True, index=True)
    img_url = Column(String(500), nullable=False)
    caption = Column(String(255))
    uploaded_at = Column(DateTime, nullable=False)
    file_size = Column(Integer)
    content_type = Column(String(30), nullable=False)
    #relationships
    #each photo has a user with a user_id
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    #each photo posted has a venue with a venue id
    venue_id = Column(Integer, ForeignKey("venues.venue_id"), nullable=False)

class Review(Base):
    __tablename__ = "reviews"
    review_id = Column(Integer, primary_key=True, index=True)
    review_text = Column(Text, nullable=False)
    created_at = Column(DateTime, default=func.now(), nullable=False)

    #relationships
    #each review is written by a user with a user id
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    #each review has a venue with a venue id
    venue_id = Column(Integer, ForeignKey("venues.venue_id"), nullable=False)


class Rating(Base):
    __tablename__ = "ratings"
    rating_id = Column(Integer, primary_key=True, index=True)
    rating = Column(Float, nullable=False)
    created_at = Column(DateTime, default=func.now(), nullable=False)

    #relationships
    #each rating is by a user
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    #each rating is for a venue
    venue_id = Column(Integer, ForeignKey("venues.venue_id"), nullable=False)

    __table_args__ = (
        CheckConstraint('rating <= 5'),
        CheckConstraint('rating > 0'),
        # Ensure one rating per user per venue
        UniqueConstraint('user_id', 'venue_id', name='unique_user_venue_rating'),
    )


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
    price = Column(Integer, nullable=False)
    #relationships
    reviews = relationship("Review", backref="venue", cascade="all, delete-orphan")
    photos = relationship("Photo", backref="venue", cascade="all, delete-orphan")
    ratings = relationship("Rating", backref="venue", cascade="all, delete-orphan")

