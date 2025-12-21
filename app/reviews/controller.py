from fastapi import APIRouter, Form, HTTPException
from starlette import status
from typing import Optional
from app.core.database import DbSession
from . import r_model
from . import service
from app.auth.service import CurrentUser
from app.models.models import Review

router = APIRouter(
    prefix="/reviews",
    tags=["reviews"]
)


# noinspection PyTypeHints
@router.post("/upload-review", status_code=status.HTTP_201_CREATED)
def upload_review(db: DbSession,
                  current_user: CurrentUser,
                  venue_id: int = Form(...),
                  review_text: str = Form(...)):
    current_user_id = current_user.get_id()
    review_data = r_model.CreateReview(
        venue_id=venue_id,
        review_text=review_text
    )

    review = service.create_review(db, review_data, current_user_id)

    return r_model.ReviewResponse(
        review_id=review.review_id,
        created_at=review.created_at,
        user_id=current_user_id,
        venue_id=review.venue_id,
        review_text=review.review_text,
        username=review.user.username,
        venue_name=review.venue.venue_name
    )


# noinspection PyTypeHints
@router.delete("/delete-review", status_code=status.HTTP_204_NO_CONTENT)
def delete_review(db: DbSession, review_id: int, current_user: CurrentUser):
    # Get the review to check ownership
    review = db.query(Review).filter(Review.review_id == review_id).first()
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")
    
    # Check authorization
    if review.user_id != current_user.get_id():
        raise HTTPException(status_code=403, detail="Not authorized to delete this review")
    
    # Delete the review
    service.delete_review(db, review_id, current_user.get_id())


# noinspection PyTypeHints
@router.get("/venues/{venue_id}", status_code=status.HTTP_200_OK)
def get_venue_reviews(db: DbSession, venue_id: int, after_review_id: Optional[int] = None, limit: int = 20):
    reviews = service.get_reviews_by_venue(db, venue_id, after_review_id, limit)
    return {
        'reviews': [r_model.ReviewResponse(
            review_id=review.review_id,
            created_at=review.created_at,
            user_id=review.user_id,
            venue_id=review.venue_id,
            review_text=review.review_text,
            username=review.user.username,
            venue_name=review.venue.venue_name
        ) for review in reviews],
        "has_more": len(reviews) == limit,
        'next_cursor': reviews[-1].review_id if reviews else None
    }


@router.get("/users/{user_id}", status_code=status.HTTP_200_OK)
def get_user_reviews(db: DbSession, user_id: int, after_review_id: Optional[int] = None, limit: int = 20):
    reviews = service.get_reviews_by_user(db, user_id, after_review_id, limit)
    return {
        'reviews': [r_model.ReviewResponse(
            review_id=review.review_id,
            created_at=review.created_at,
            user_id=review.user_id,
            venue_id=review.venue_id,
            review_text=review.review_text,
            username=review.user.username,
            venue_name=review.venue.venue_name
        ) for review in reviews],
        "has_more": len(reviews) == limit,
        'next_cursor': reviews[-1].review_id if reviews else None
    }


# noinspection PyTypeHints
@router.put("/update-review/{review_id}", status_code=status.HTTP_200_OK)
def update_review(db: DbSession, current_user: CurrentUser, review_id: int,
                  review_text: str = Form(...)):
    review_data = r_model.UpdateReview(review_text=review_text)
    current_user_id = current_user.get_id()
    updated_review = service.update_review(db, review_id, review_data, current_user_id)

    return r_model.ReviewResponse(
        review_id=updated_review.review_id,
        created_at=updated_review.created_at,
        user_id=updated_review.user_id,
        venue_id=updated_review.venue_id,
        review_text=updated_review.review_text,
        username=updated_review.user.username,
        venue_name=updated_review.venue.venue_name
    )
