#what data is accepted and what do my tables look like
from enum import Enum
from sqlalchemy import Column, Integer, String, DateTime, Float, CheckConstraint, Text, ForeignKey, Enum as SQEnum
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
    rating = Column(Float, nullable=True)  # Nullable for replies
    review_text = Column(Text)
    created_at = Column(DateTime, default=func.now(), nullable=False)

    # For reply functionality
    parent_review_id = Column(Integer, ForeignKey("reviews.review_id"), nullable=True)

    __table_args__ = (
        CheckConstraint('rating <= 5'),
        CheckConstraint('rating > 0')
    )

    #relationships
    #each review is written by a user with a user id
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    #each review has a venue with a venue id
    venue_id = Column(Integer, ForeignKey("venues.venue_id"), nullable=False)
    #replies relationship
    replies = relationship("Review", backref="parent", remote_side=[review_id])


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
    reviews = relationship("Review", backref="venue")
    photos = relationship("Photo", backref="venue")

