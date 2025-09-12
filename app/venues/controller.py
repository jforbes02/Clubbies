from fastapi import APIRouter, status, Query, HTTPException
from app.core.database import DbSession
from app.auth.service import CurrentUser
from . import v_models
from . import service
from ..models.models import Venue
from typing import List, Optional

router = APIRouter(
    prefix="/venues",
    tags=["venues"]
)


# noinspection PyTypeHints
@router.post("/", status_code=status.HTTP_201_CREATED)
def create_venue(db: DbSession, venue_data: v_models.VenueCreate, current_user: CurrentUser):
    # Admin-only venue creation
    user = db.query(Venue).join(User).filter(User.user_id == current_user.get_id()).first()
    # Add proper admin role system

    venue = service.create_venue(db, venue_data)
    return v_models.VenueResponse(
        venue_id=venue.venue_id,
        venue_name=venue.venue_name,
        address=venue.address,
        hours=venue.hours,
        venue_type=venue.venue_type,
        age_req=venue.age_req,
        description=venue.description,
        capacity=venue.capacity,
        price=venue.price
    )


# noinspection PyTypeHints
@router.get("/{venue_id}", response_model=v_models.VenueResponse)
def get_venue(db: DbSession, venue_id: int):
    return service.get_venue_by_id(db, venue_id)


# noinspection PyTypeHints
@router.delete("/{venue_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_venue(db: DbSession, venue_id: int):
    # Add admin check here
    service.delete_venue(db, venue_id)


# noinspection PyTypeHints
@router.get("/", status_code=status.HTTP_200_OK)
def get_all_venues(db: DbSession, after_venue_id: Optional[int] = None, limit: int = 20):
    venues = service.get_all_venues(db, after_venue_id, limit)
    return {
        'venues': [v_models.VenueResponse(
            venue_id=venue.venue_id,
            venue_name=venue.venue_name,
            address=venue.address,
            hours=venue.hours,
            venue_type=venue.venue_type,
            age_req=venue.age_req,
            description=venue.description,
            capacity=venue.capacity,
            price=venue.price
        ) for venue in venues],
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
        'venues': [v_models.VenueResponse(
            venue_id=venue.venue_id,
            venue_name=venue.venue_name,
            address=venue.address,
            hours=venue.hours,
            venue_type=venue.venue_type,
            age_req=venue.age_req,
            description=venue.description,
            capacity=venue.capacity,
            price=venue.price
        ) for venue in venues],
        "has_more": len(venues) == limit,
        'next_cursor': venues[-1].venue_id if venues else None
    }


# noinspection PyTypeHints
@router.put("/{venue_id}", status_code=status.HTTP_200_OK)
def update_venue(venue_id: int, venue_change: v_models.VenueUpdate,
                 db: DbSession, current_user: CurrentUser):
    #Add admin check here
    updated_venue = service.update_venue(db, venue_id, venue_change)
    return v_models.VenueResponse(
        venue_id=updated_venue.venue_id,
        venue_name=updated_venue.venue_name,
        address=updated_venue.address,
        hours=updated_venue.hours,
        venue_type=updated_venue.venue_type,
        age_req=updated_venue.age_req,
        description=updated_venue.description,
        capacity=updated_venue.capacity,
        price=updated_venue.price
    )

