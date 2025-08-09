from sqlalchemy.orm import Session
from sqlalchemy import or_, and_
from fastapi import HTTPException
from .v_models import VenueCreate, VenueUpdate
from app.models.models import Venue
import logging

def create_venue(self, db: Session, venue_data: VenueCreate) -> Venue:
    existing = db.query(Venue).filter().first()

    if existing:
        raise HTTPException(status_code=400, detail="Venue already exists")

    venue = Venue(
        venue_name=venue_data.venue_name,
        venue_type=venue_data.venue_type,
        address=venue_data.address,
        age_req=venue_data.age_req,
        hours=venue_data.hours,
    )
    db.add(venue)
    db.commit()
    db.refresh(venue)
    return venue
