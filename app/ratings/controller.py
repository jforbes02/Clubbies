from fastapi import APIRouter, Form, HTTPException
from starlette import status
from app.core.database import DbSession
from . import rating_models
from . import service
from app.auth.service import CurrentUser
from app.venues import v_models
from app.models.models import Review, Rating
from sqlalchemy import func

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


@router.get("/user/venues", status_code=status.HTTP_200_OK)
def get_user_rated_venues(db: DbSession, current_user: CurrentUser):
    """Get all venues rated by the current user"""
    current_user_id = current_user.get_id()
    venues = service.get_user_rated_venues(db, current_user_id)

    # Build venue responses with rating data
    venue_responses = []
    for venue in venues:
        review_count = db.query(func.count(Review.review_id)).filter(
            Review.venue_id == venue.venue_id
        ).scalar() or 0

        avg_rating = db.query(func.avg(Rating.rating)).filter(
            Rating.venue_id == venue.venue_id
        ).scalar()

        average_rating = round(float(avg_rating), 2) if avg_rating else 0.0

        venue_response = v_models.VenueResponse(
            venue_id=venue.venue_id,
            venue_name=venue.venue_name,
            address=venue.address,
            hours=venue.hours,
            venue_type=venue.venue_type,
            age_req=venue.age_req,
            description=venue.description,
            capacity=venue.capacity,
            price=venue.price,
            average_rating=average_rating,
            review_count=review_count
        )
        venue_responses.append(venue_response)

    return {"venues": venue_responses}
