from http.client import HTTPException

from sqlalchemy.orm import Session
from . import r_model
from app.models.models import User, Venue, Review
import logging

async def create_review(db: Session, review_data: r_model.CreateReview, user_id: int) -> Review:
    try:
        venue = db.query(Review).filter(Venue.venue_id == review_data.venue_id).first()
        if not venue:
            logging.error(f"Venue {review_data.venue_id} does not exist")
            raise HTTPException(status_code=404, detail="Review not found")

        user = db.query(User).filter(User.user_id == user_id).first()
        if not user:
            logging.error(f"User {user_id} does not exist")
            raise HTTPException(status_code=404, detail="User not found")