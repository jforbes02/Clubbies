from fastapi import APIRouter, Form, HTTPException
from starlette import status
from app.core.database import DbSession
from . import rating_models
from . import service
from app.auth.service import CurrentUser

router = APIRouter(
    prefix="/ratings",
    tags=["ratings"]
)


@router.post("/submit", status_code=status.HTTP_201_CREATED)
def submit_rating(
    db: DbSession,
    current_user: CurrentUser,
    venue_id: int = Form(...),
    rating: float = Form(...)
):
    """Submit or update a rating for a venue"""
    current_user_id = current_user.get_id()
    rating_data = rating_models.CreateRating(
        venue_id=venue_id,
        rating=rating
    )

    rating_obj = service.create_or_update_rating(db, rating_data, current_user_id)

    return rating_models.RatingResponse(
        rating_id=rating_obj.rating_id,
        rating=rating_obj.rating,
        created_at=rating_obj.created_at,
        user_id=current_user_id,
        venue_id=rating_obj.venue_id
    )


@router.get("/user/venue/{venue_id}", status_code=status.HTTP_200_OK)
def get_user_rating(db: DbSession, current_user: CurrentUser, venue_id: int):
    """Get the current user's rating for a specific venue"""
    current_user_id = current_user.get_id()
    rating = service.get_user_rating_for_venue(db, current_user_id, venue_id)

    if not rating:
        return {"rating": None}

    return rating_models.RatingResponse(
        rating_id=rating.rating_id,
        rating=rating.rating,
        created_at=rating.created_at,
        user_id=rating.user_id,
        venue_id=rating.venue_id
    )


@router.delete("/{rating_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_rating(db: DbSession, current_user: CurrentUser, rating_id: int):
    """Delete a rating"""
    current_user_id = current_user.get_id()
    service.delete_rating(db, rating_id, current_user_id)
