from fastapi import HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.models import Rating
from . import rating_models
import logging


def create_or_update_rating(db: Session, rating_data: rating_models.CreateRating, user_id: int) -> Rating:
    """Create a new rating or update existing one for the user-venue pair"""
    try:
        # Check if user already has a rating for this venue
        existing_rating = db.query(Rating).filter(
            Rating.user_id == user_id,
            Rating.venue_id == rating_data.venue_id
        ).first()

        if existing_rating:
            # Update existing rating
            existing_rating.rating = rating_data.rating
            db.commit()
            db.refresh(existing_rating)
            logging.info(f"Rating updated by user {user_id} for venue {rating_data.venue_id}")
            return existing_rating
        else:
            # Create new rating
            new_rating = Rating(
                rating=rating_data.rating,
                user_id=user_id,
                venue_id=rating_data.venue_id
            )
            db.add(new_rating)
            db.commit()
            db.refresh(new_rating)
            logging.info(f"Rating created by user {user_id} for venue {rating_data.venue_id}")
            return new_rating

    except Exception as e:
        db.rollback()
        logging.error(f"Error creating/updating rating: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")


def get_user_rating_for_venue(db: Session, user_id: int, venue_id: int) -> Rating | None:
    """Get a user's rating for a specific venue"""
    try:
        rating = db.query(Rating).filter(
            Rating.user_id == user_id,
            Rating.venue_id == venue_id
        ).first()
        return rating
    except Exception as e:
        logging.error(f"Error fetching user rating: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")


def delete_rating(db: Session, rating_id: int, user_id: int) -> None:
    """Delete a rating"""
    try:
        rating = db.query(Rating).filter(Rating.rating_id == rating_id).first()
        if not rating:
            raise HTTPException(status_code=404, detail="Rating not found")

        if rating.user_id != user_id:
            raise HTTPException(status_code=403, detail="Not authorized to delete this rating")

        db.delete(rating)
        db.commit()
        logging.info(f"Rating {rating_id} deleted by user {user_id}")

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logging.error(f"Error deleting rating: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")
