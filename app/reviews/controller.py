from fastapi import APIRouter, Form
from starlette import status
from typing import Optional
from app.core.database import DbSession
from . import r_model
from . import service

router = APIRouter(
    prefix="/reviews",
    tags=["reviews"]
)


# noinspection PyTypeHints
@router.post("/upload-review", status_code=status.HTTP_201_CREATED)
def upload_review(db:DbSession,
                        current_user_id: int,
                        venue_id: int = Form(...),
                        rating: float = Form(...),
                        review_text: Optional[str] = Form(None)):
    review_data = r_model.CreateReview(venue_id=venue_id, rating=rating, review_text=review_text)

    review = service.create_review(db, review_data, current_user_id)

    return r_model.ReviewResponse(
        review_id=review.review_id,
        rating=review.rating,
        created_at=review.created_at,
        user_id=current_user_id,
        venue_id=review.venue_id,
        review_text=review.review_text,
        username=review.user.username,
        venue_name=review.venue.venue_name
    )


# noinspection PyTypeHints
@router.delete("/delete-review", status_code=status.HTTP_204_NO_CONTENT)
def delete_review(db:DbSession, review_id: int, current_user_id: int):
    service.delete_review(db, review_id, current_user_id)


# noinspection PyTypeHints
@router.get("/venue/{venue_id}/reviews", status_code=status.HTTP_200_OK)
def get_reviews_by_venue(db:DbSession, venue_id: int, after_review_id: int = None, limit: int=20):
    reviews = service.get_reviews_by_venue(db, venue_id, after_review_id, limit)
    return [r_model.ReviewResponse(
        review_id=review.review_id,
        rating=review.rating,
        created_at=review.created_at,
        user_id=review.user_id,
        venue_id=review.venue_id,
        review_text=review.review_text,
        username=review.user.username,
        venue_name=review.venue.venue_name
    ) for review in reviews]


# noinspection PyTypeHints
@router.put("/update-review/{review_id}", status_code=status.HTTP_200_OK)
def update_review(db: DbSession, current_user_id: int, review_id: int,
                  rating: Optional[float] = Form(None), review_text: Optional[str] = Form(None)):
    review_data = r_model.UpdateReview(rating=rating, review_text=review_text)
    updated_review = service.update_review(db, review_id, review_data, current_user_id)

    return r_model.ReviewResponse(
        review_id=updated_review.review_id,
        rating=updated_review.rating,
        created_at=updated_review.created_at,
        user_id=updated_review.user_id,
        venue_id=updated_review.venue_id,
        review_text=updated_review.review_text,
        username=updated_review.user.username,
        venue_name=updated_review.venue.venue_name
    )
