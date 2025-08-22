from fastapi import HTTPException

from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func
from . import r_model
from app.models.models import User, Venue, Review
import logging

def create_review(db: Session, review_data: r_model.CreateReview, user_id: int) -> Review:
    try:
        venue = db.query(Venue).filter(Venue.venue_id == review_data.venue_id).first()
        if not venue:
            logging.error(f"Venue {review_data.venue_id} does not exist")
            raise HTTPException(status_code=404, detail="Review not found")

        user = db.query(User).filter(User.user_id == user_id).first()
        if not user:
            logging.error(f"User {user_id} does not exist")
            raise HTTPException(status_code=404, detail="User not found")

        # Check if user already reviewed this venue
        existing_review = db.query(Review).filter(
            Review.user_id == user_id,
            Review.venue_id == review_data.venue_id
        ).first()
        
        if existing_review:
            logging.error(f"User {user_id} already reviewed venue {review_data.venue_id}")
            raise HTTPException(status_code=400, detail="User has already reviewed this venue")

        review = Review(
            rating=review_data.rating,
            review_text=review_data.review_text,
            user_id=user_id,
            venue_id=review_data.venue_id
        )
        
        db.add(review)
        db.commit()
        db.refresh(review)

        review_rel = db.query(Review).options(
            joinedload(Review.user), 
            joinedload(Review.venue)
        ).filter(Review.review_id == review.review_id).first()
        logging.info(f"Review created successfully by user {user_id} for venue {review_data.venue_id}")
        return review_rel
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logging.error(f"Error creating review: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")


def get_reviews_by_venue(db: Session, venue_id: int, after_review_id: int = None, limit: int = 20) -> list[Review]:
    try:
        venue = db.query(Venue).filter(Venue.venue_id == venue_id).first()
        if not venue:
            raise HTTPException(status_code=404, detail="Venue not found")
            
        query = db.query(Review).filter(Review.venue_id == venue_id)
        
        if after_review_id:
            query = query.filter(Review.review_id > after_review_id)
            
        reviews = query.order_by(Review.review_id.asc()).limit(limit).all()
        
        return reviews
        
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Error fetching reviews for venue {venue_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")


def get_reviews_by_user(db: Session, user_id: int, after_review_id: int = None, limit: int = 20) -> list[Review]:
    try:
        user = db.query(User).filter(User.user_id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
            
        query = db.query(Review).filter(Review.user_id == user_id)
        
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
            
        if review_data.rating is not None:
            review.rating = review_data.rating
        if review_data.review_text is not None:
            review.review_text = review_data.review_text
            
        db.commit()
        db.refresh(review)
        
        logging.info(f"Review {review_id} updated successfully by user {user_id}")
        return review
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logging.error(f"Error updating review {review_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")


def delete_review(db: Session, review_id: int, user_id: int) -> bool:
    try:
        review = db.query(Review).filter(Review.review_id == review_id).first()
        if not review:
            raise HTTPException(status_code=404, detail="Review not found")
            
        if review.user_id != user_id:
            raise HTTPException(status_code=403, detail="Not authorized to delete this review")
            
        db.delete(review)
        db.commit()
        
        logging.info(f"Review {review_id} deleted successfully by user {user_id}")
        return True
        
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