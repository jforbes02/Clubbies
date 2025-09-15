from sqlalchemy.orm import Session
from fastapi import HTTPException
from . import v_models
from app.models.models import Venue
import logging
from typing import List, Optional


def create_venue(db: Session, venue_data: v_models.VenueCreate) -> Venue:
    try:
        existing = db.query(Venue).filter(
            Venue.venue_name == venue_data.venue_name, Venue.address == venue_data.address
        ).first()

        if existing:
            raise HTTPException(status_code=400, detail="Venue already exists")

        venue = Venue(
            venue_name=venue_data.venue_name,
            venue_type=venue_data.venue_type,
            address=venue_data.address,
            age_req=venue_data.age_req,
            hours=venue_data.hours,
            price=venue_data.price,
            capacity=venue_data.capacity,
            description=venue_data.description,
        )

        db.add(venue)
        db.commit()
        db.refresh(venue)
        logging.info(f"Created venue: {venue.venue_name}")
        return venue
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logging.error(f"Failed to create venue: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to create venue")

def get_venue_by_id(db: Session, venue_id: int) -> Venue:
    venue = db.query(Venue).get(venue_id)
    if not venue:
        raise HTTPException(status_code=404, detail="Venue not found")
    return venue

def update_venue(db: Session, venue_id: int, change_venue: v_models.VenueUpdate) -> Venue:
    try:
        venue = get_venue_by_id(db, venue_id)
        update_data = change_venue.model_dump(exclude_unset=True)

        for key, value in update_data.items():
            setattr(venue, key, value)
        db.commit()
        db.refresh(venue)
        logging.info(f"Venue {venue.venue_name} updated")
        return venue
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logging.error(f"Failed to update venue {venue_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to update venue")

def delete_venue(db: Session, venue_id: int) -> None:
    try:
        venue = get_venue_by_id(db, venue_id)  # sees if venue exists
        db.delete(venue)
        db.commit()
        logging.info(f"Venue {venue.venue_name} deleted, ID: {venue_id}")
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logging.error(f"Failed to delete venue {venue_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to delete venue")


# noinspection PyTypeChecker
def get_all_venues(db: Session, after_venue_id: int = None, limit: int = 20) -> List[Venue]:
    try:
        query = db.query(Venue)
        
        if after_venue_id:
            query = query.filter(Venue.venue_id > after_venue_id)
            
        venues = query.order_by(Venue.venue_id.asc()).limit(limit).all()
        logging.info(f"Retrieved {len(venues)} venues")
        return venues
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Error fetching venues: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch venues")


# noinspection PyTypeChecker
def search_venue(db: Session, venue_name: Optional[str], special_filter: v_models.VenueFilter, after_venue_id: int = None, limit: int = 20) -> List[Venue]:
    try:
        query = db.query(Venue)

        if venue_name:
            query = query.filter(Venue.venue_name.ilike(f"%{venue_name}%"))

        #have to in the future figure out capacity filtering.

        #hours open filters
        if special_filter.hours:
            query = query.filter(Venue.hours.ilike(f"%{special_filter.hours}%"))
        #price filter
        if special_filter.max_price:
            query = query.filter(Venue.price <= special_filter.max_price)
        #age filter
        if special_filter.min_age:
            query = query.filter(Venue.age_req <= special_filter.min_age)
        #venue_type filter
        if special_filter.venue_type:
            query = query.filter(Venue.venue_type.any(special_filter.venue_type))
        #location search
        if special_filter.location_search:
            query = query.filter(Venue.address.ilike(f"%{special_filter.location_search}%"))

        if after_venue_id:
            query = query.filter(Venue.venue_id > after_venue_id)
            
        venues = query.order_by(Venue.venue_id.asc()).limit(limit).all()

        logging.info(f"Found {len(venues)} venues")
        return venues
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Error searching venues: {str(e)}")
        raise HTTPException(status_code=500, detail="Venue search failed")