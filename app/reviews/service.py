from fastapi import HTTPException

from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func
from app.auth.service import CurrentUser
from . import r_model
from app.models.models import User, Venue, Review
import logging
from typing import List


# noinspection PyTypeChecker
def create_review(db: Session, review_data: r_model.CreateReview, user_id: int) -> Review:
    try:
        # If it's a reply (has parent_review_id), different validation
        if review_data.parent_review_id:
            # Verify parent review exists
            parent_review = db.query(Review).filter(Review.review_id == review_data.parent_review_id).first()
            if not parent_review:
                raise HTTPException(status_code=404, detail="Parent review not found")

            # Replies don't need a rating
            if not review_data.review_text:
                raise HTTPException(status_code=400, detail="Reply must have text")

            review = Review(
                rating=None,  # Replies don't have ratings
                review_text=review_data.review_text,
                user_id=user_id,
                venue_id=review_data.venue_id,
                parent_review_id=review_data.parent_review_id
            )
        else:
            # It's a main review, check if user already reviewed this venue
            existing_review = db.query(Review).filter(
                Review.user_id == user_id,
                Review.venue_id == review_data.venue_id,
                Review.parent_review_id == None  # Only check main reviews
            ).first()

            if existing_review:
                logging.error(f"User {user_id} already reviewed venue {review_data.venue_id}")
                raise HTTPException(status_code=400, detail="User has already reviewed this venue")

            # Main reviews must have a rating
            if not review_data.rating:
                raise HTTPException(status_code=400, detail="Main review must have a rating")

            review = Review(
                rating=review_data.rating,
                review_text=review_data.review_text,
                user_id=user_id,
                venue_id=review_data.venue_id,
                parent_review_id=None
            )

        db.add(review)
        db.commit()

        # Refresh with relationships loaded
        db.refresh(review)
        review_rel = db.query(Review).options(
            joinedload(Review.user),
            joinedload(Review.venue)
        ).filter(Review.review_id == review.review_id).first()

        if review_data.parent_review_id:
            logging.info(f"Reply created successfully by user {user_id} for review {review_data.parent_review_id}")
        else:
            logging.info(f"Review created successfully by user {user_id} for venue {review_data.venue_id}")
        return review_rel

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logging.error(f"Error creating review: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")


# noinspection PyTypeChecker
def get_reviews_by_venue(db: Session, venue_id: int, after_review_id: int = None, limit: int = 20) -> List[Review]:
    try:
        # Only get top-level reviews (not replies)
        query = db.query(Review).options(
            joinedload(Review.user),
            joinedload(Review.venue)
        ).filter(
            Review.venue_id == venue_id,
            Review.parent_review_id == None
        )

        if after_review_id:
            query = query.filter(Review.review_id > after_review_id)

        reviews = query.order_by(Review.created_at.desc()).limit(limit).all()

        return reviews

    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Error fetching reviews for venue {venue_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")


# noinspection PyTypeChecker
def get_replies_by_review(db: Session, review_id: int, limit: int = 50) -> List[Review]:
    try:
        # Get all replies for a specific review
        reviews = db.query(Review).options(
            joinedload(Review.user),
            joinedload(Review.venue)
        ).filter(
            Review.parent_review_id == review_id
        ).order_by(Review.created_at.asc()).limit(limit).all()

        return reviews

    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Error fetching replies for review {review_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")


# noinspection PyTypeChecker
def get_reviews_by_user(db: Session, user_id: int, after_review_id: int = None, limit: int = 20) -> List[Review]:
    try:
        # Let foreign key constraint handle user validation  
        query = db.query(Review).options(
            joinedload(Review.user),
            joinedload(Review.venue)
        ).filter(Review.user_id == user_id)
        
        if after_review_id:
            query = query.filter(Review.review_id > after_review_id)
            
        reviews = query.order_by(Review.review_id.asc()).limit(limit).all()
        
        return reviews
        
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Error fetching reviews for user {user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")


def update_review(db: Session, review_id: int, review_data: r_model.UpdateReview, user_id: int) -> Review:
    try:
        review = db.query(Review).filter(Review.review_id == review_id).first()
        if not review:
            raise HTTPException(status_code=404, detail="Review not found")
            
        if review.user_id != user_id:
            raise HTTPException(status_code=403, detail="Not authorized to update this review")
        
        # Check if at least one field is being updated
        if review_data.rating is None and review_data.review_text is None:
            raise HTTPException(status_code=400, detail="At least one field must be provided for update")
            
        if review_data.rating is not None:
            review.rating = review_data.rating
        if review_data.review_text is not None:
            review.review_text = review_data.review_text
            
        db.commit()
        db.refresh(review)
        
        # Return review with relationships loaded
        updated_review = db.query(Review).options(
            joinedload(Review.user),
            joinedload(Review.venue)
        ).filter(Review.review_id == review_id).first()
        
        logging.info(f"Review {review_id} updated successfully by user {user_id}")
        return updated_review
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logging.error(f"Error updating review {review_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")


def delete_review(db: Session, review_id: int, user_id: int) -> None:
    try:
        review = db.query(Review).filter(Review.review_id == review_id).first()
        if not review:
            raise HTTPException(status_code=404, detail="Review not found")
            
        if review.user_id != user_id:
            raise HTTPException(status_code=403, detail="Not authorized to delete this review")
            
        db.delete(review)
        db.commit()
        
        logging.info(f"Review {review_id} deleted successfully by user {user_id}")
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logging.error(f"Error deleting review {review_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")


async def get_venue_average_rating(db: Session, venue_id: int) -> float:
    try:

        result = db.query(func.avg(Review.rating)).filter(
            Review.venue_id == venue_id
        ).scalar()
        
        return round(result, 2) if result else 0.0
        
    except Exception as e:
        logging.error(f"Error calculating average rating for venue {venue_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")