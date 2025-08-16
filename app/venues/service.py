from sqlalchemy.orm import Session
from fastapi import HTTPException
from . import v_models
from app.models.models import Venue
import logging
from typing import List

def create_venue(db: Session, venue_data: v_models.VenueCreate) -> Venue:
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

    return venue

def get_venue_by_id(db: Session, venue_id: int) -> Venue:
    venue = db.query(Venue).get(venue_id)
    if not venue:
        raise HTTPException(status_code=404, detail="Venue not found")
    return venue

def update_venue(db: Session,venue_id: int, change_venue: v_models.VenueUpdate) -> None:
    try:
        venue = get_venue_by_id(db, venue_id)
        update_data = change_venue.model_dump(exclude_unset=True)

        for key, value in update_data.items():
            setattr(venue, key, value)
        db.commit()
        logging.info(f"Venue {venue.venue_name} updated")
    except HTTPException as e:
        logging.error("could not find Venue")
        raise e

def delete_venue(db: Session, venue_id: int) -> None:
    try:
        venue = get_venue_by_id(db, venue_id) #sees if venue exists
        db.delete(venue)
        db.commit()
        logging.info(f"Venue {venue_id} deleted, ID: {venue_id}")
    except HTTPException as e:
        logging.error("could not find Venue")
        raise e

def search_venue(db: Session, venue_name: str, special_filter: v_models.VenueFilter) -> List[Venue]:
    try:
        query = db.query(Venue)

        if venue_name:
            query = query.filter(Venue.venue_name.ilike(f"%{venue_name}%"))

        #capacity filters
        if special_filter.min_capacity:
            query = query.filter(Venue.capacity >= special_filter.min_capacity)
        if special_filter.max_capacity:
            query = query.filter(Venue.capacity <= special_filter.max_capacity)



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
            query = query.filter(Venue.venue_type == special_filter.venue_type)
        #location search
        if special_filter.location_search:
            query = query.filter(Venue.address.ilike(f"%{special_filter.location_search}%"))

        venues = query.all()

        logging.info(f"Found {len(venues)} venues")
        return venues
    except Exception as e:
        logging.error(f"could not find Venue's searched for")
        return []