from pydantic import BaseModel, Field
from ..models.models import VenueType,VenueCapacity
from typing import Optional, List

#model for creating venues (input)
class VenueBase(BaseModel):
    venue_name: str = Field(..., max_length=255, description="Name of venue")
    address: str = Field(..., max_length=255)
    venue_type: List[VenueType] = Field(..., min_items=1, max_items=3, description="Classification of the venue")
    age_req: int = Field(..., ge=16)
    capacity: VenueCapacity = Field(..., description="How much space the venue has")
    description: Optional[str] = Field(None, max_length=255)
    hours: str = Field(..., max_length=100)
    price: int = Field(...)
class VenueCreate(VenueBase):
    pass

#output of venue data
class VenueResponse(VenueBase):
    venue_id: int
"""
    venue_name: str
    address: str
    hours: str
    venue_type: List[VenueType]
    age_req: int
    description: Optional[str] = None
    capacity: VenueCapacity = None
"""

#update venue data
class VenueUpdate(BaseModel):
    hours: Optional[str] = Field(None, max_length=100)
    capacity: Optional[VenueCapacity] = None
    description: Optional[str] = Field(None, max_length=255)
    venue_name: Optional[str] = Field(None, max_length=255)
    age_req: Optional[int] = Field(None, ge=16)
    address: Optional[str] = Field(None, min_length=15, max_length=255)
    price: Optional[int] = Field(None)
#search and filtering
class VenueFilter(BaseModel):
    hours: Optional[str] = Field(None, max_length=100)
    min_capacity: Optional[VenueCapacity] = None
    max_capacity: Optional[VenueCapacity] = None
    venue_type: Optional[VenueType] = Field(None, max_length=255)
    location_search: Optional[str] = Field(None, max_length=100, description="Search in address")
    max_price: Optional[int] = Field(None, ge=100)
    min_age: Optional[int] = Field(None, ge=16)


class VenueSearch(VenueBase):
    pass