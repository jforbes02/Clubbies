from fastapi import APIRouter, status, Query, HTTPException
from app.core.database import DbSession
from app.auth.service import CurrentUser, require_admin
from . import v_models
from . import service
from ..models.models import Venue, User, Review, Rating
from typing import List, Optional
from sqlalchemy import func

router = APIRouter(
    prefix="/venues",
    tags=["venues"]
)


def _build_venue_response(venue: Venue, db: DbSession) -> v_models.VenueResponse:
    """Helper function to build VenueResponse with rating data"""
    # Get review count
    review_count = db.query(func.count(Review.review_id)).filter(
        Review.venue_id == venue.venue_id
    ).scalar() or 0

    # Get average rating from ratings table
    avg_rating = db.query(func.avg(Rating.rating)).filter(
        Rating.venue_id == venue.venue_id
    ).scalar()

    average_rating = round(float(avg_rating), 2) if avg_rating else 0.0

    return v_models.VenueResponse(
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


# noinspection PyTypeHints
@router.post("/", status_code=status.HTTP_201_CREATED)
def create_venue(db: DbSession, venue_data: v_models.VenueCreate, current_user: CurrentUser):

    require_admin(current_user, db)

    venue = service.create_venue(db, venue_data)
    return _build_venue_response(venue, db)


# noinspection PyTypeHints
@router.get("/", status_code=status.HTTP_200_OK)
def get_all_venues(db: DbSession, after_venue_id: Optional[int] = None, limit: int = 20):
    venues = service.get_all_venues(db, after_venue_id, limit)
    return {
        'venues': [_build_venue_response(venue, db) for venue in venues],
        "has_more": len(venues) == limit,
        'next_cursor': venues[-1].venue_id if venues else None
    }


# noinspection PyTypeHints
@router.get("/search", status_code=status.HTTP_200_OK)
def search_venues(db: DbSession,
                  venue_name: Optional[str] = Query(None),
                  min_capacity: Optional[str] = Query(None),
                  max_capacity: Optional[str] = Query(None),
                  hours: Optional[str] = Query(None),
                  venue_type: Optional[str] = Query(None),
                  max_price: Optional[int] = Query(None),
                  min_age: Optional[int] = Query(None, ge=16),
                  location_search: Optional[str] = Query(None),
                  after_venue_id: Optional[int] = None,
                  limit: int = 20):
    filter_params = v_models.VenueFilter(
        min_capacity=min_capacity,
        max_capacity=max_capacity,
        hours=hours,
        venue_type=venue_type,
        max_price=max_price,
        min_age=min_age,
        location_search=location_search,
    )
    venues = service.search_venue(db, venue_name, filter_params, after_venue_id, limit)
    return {
        'venues': [_build_venue_response(venue, db) for venue in venues],
        "has_more": len(venues) == limit,
        'next_cursor': venues[-1].venue_id if venues else None
    }


# noinspection PyTypeHints
@router.get("/{venue_id}", response_model=v_models.VenueResponse)
def get_venue(db: DbSession, venue_id: int):
    venue = service.get_venue_by_id(db, venue_id)
    return _build_venue_response(venue, db)


# noinspection PyTypeHints
@router.delete("/{venue_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_venue(db: DbSession, venue_id: int, current_user: CurrentUser):
    require_admin(current_user, db)
    service.delete_venue(db, venue_id)


# noinspection PyTypeHints
@router.put("/{venue_id}", status_code=status.HTTP_200_OK)
def update_venue(venue_id: int, venue_change: v_models.VenueUpdate,
                 db: DbSession, current_user: CurrentUser):
    require_admin(current_user, db)
    updated_venue = service.update_venue(db, venue_id, venue_change)
    return _build_venue_response(updated_venue, db)

