from fastapi import APIRouter, status, Query
from app.core.database import DbSession
from . import v_models
from . import service
from ..models.models import Venue
from typing import List, Optional
router = APIRouter(
    prefix="/venues",
    tags=["venues"]
)

@router.get("/", status_code=status.HTTP_200_OK)
def create_venue(db:DbSession, venue_data: v_models.VenueCreate):
    return service.create_venue(db, venue_data)

@router.get("/{venue_id}", response_model=v_models.VenueResponse)
def get_venue(db: DbSession, venue_id: int):
    return service.get_venue_by_id(db, venue_id)

@router.delete("/{venue_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_venue(db: DbSession, venue_id: int):
    service.delete_venue(db, venue_id)

@router.get("/get_venues", response_model=List[v_models.VenueResponse])
def get_all_venues(db: DbSession):
    venues = db.query(Venue).all()
    return venues

@router.get("/filter-search", response_model=List[v_models.VenueResponse])
def search_venues(db: DbSession,
                  venue_name: Optional[str] = Query(None) ,
                  min_capacity: Optional[str] = Query(None),
                  max_capacity: Optional[str] = Query(None),
                  hours: Optional[str] = Query(None),
                  venue_type: Optional[str] = Query(None),
                  max_price: Optional[int] = Query(None),
                  min_age: Optional[int] = Query(None, ge=16),
                  location_search: Optional[str] = Query(None),
                  ):
    filter_params = v_models.VenueFilter(
        min_capacity=min_capacity,
        max_capacity=max_capacity,
        hours=hours,
        venue_type=venue_type,
        max_price=max_price,
        min_age=min_age,
        location_search=location_search,
    )
    venues = service.search_venue(db, venue_name, filter_params)
    return venues


@router.put("/update-venue/{venue_id}", status_code=status.HTTP_200_OK)
def change_venue(venue_id: int, venue_change: v_models.VenueUpdate,
                 db: DbSession):
    service.update_venue(db, venue_id, venue_change)

