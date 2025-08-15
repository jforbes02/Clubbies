from fastapi import APIRouter, status
from app.core.database import DbSession
from . import v_models
from . import service
from ..models.models import Venue
from typing import List
router = APIRouter(
    prefix="/venues",
    tags=["venues"],
)

router.get("/", response_model=List[v_models.VenueResponse])
def search_venues(db: DbSession, ):


router.put("/update-venue", status_code=status.HTTP_200_OK)
def change_venue(venue_change: v_models.VenueUpdate,
                 db: DbSession):
    service.update_venue(db, venue_change)

