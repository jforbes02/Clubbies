from typing import Optional

from fastapi import APIRouter, UploadFile, File, Form, Depends
from starlette import status
from app.core.database import DbSession
from app.auth.service import CurrentUser, require_admin
from . import p_model
from . import service
from app.models.models import Photo
from fastapi import HTTPException

router = APIRouter(
    prefix='/photo',
    tags=['photo']
)


# noinspection PyTypeHints
@router.post("/upload", status_code=status.HTTP_200_OK)
async def upload_photo(db: DbSession,
                       current_user: CurrentUser,
                       file: UploadFile = File(...),
                       venue_id: int = Form(...),
                       caption: Optional[str] = Form(None)):
    # Check if user is admin
    require_admin(current_user, db)

    current_user_id = current_user.get_id()
    photo_data = p_model.PhotoBase(venue_id=venue_id, caption=caption)
    photo = await service.create_photo(db, photo_data, current_user_id, file)

    return p_model.PhotoResponse(
        photo_id=photo.photo_id,
        img_url=photo.img_url,
        caption=photo.caption,
        file_size=photo.file_size,
        username=photo.user.username,
        uploaded_at=photo.uploaded_at,
        venue_id=photo.venue_id,
        user_id=current_user_id,
        venue_name=photo.venue.venue_name,
        content_type=photo.content_type
    )


# noinspection PyTypeHints
@router.delete("/delete-photo", status_code=status.HTTP_204_NO_CONTENT)
def delete_photo(db: DbSession, photo_id: int, current_user: CurrentUser):
    photo = service.get_photo_by_id(db, photo_id)

    if photo.user_id != current_user.get_id():
        raise HTTPException(status_code=403, detail="You are not authorized to delete this photo")
    else:
        service.delete_photo(db, photo_id)

# noinspection PyTypeHints
@router.put("/update-photo", status_code=status.HTTP_204_NO_CONTENT)
async def update_photo(db: DbSession, photo_id: int, new_caption: str, current_user: CurrentUser):
    photo = service.get_photo_by_id(db, photo_id)
    if photo.user_id != current_user.get_id():
        raise HTTPException(status_code=403, detail="You are not authorized to update this photo's caption")
    service.change_photo_caption(db, photo_id, new_caption)


@router.get("/venues/{venue_id}")
def get_venue_photos(db: DbSession, venue_id: int, after_photo_id:
Optional[int] = None, limit: int = 20):
    photos = service.get_photos_by_venue(db, venue_id,
                                         after_photo_id, limit)

    # Convert SQLAlchemy objects to Pydantic models
    photo_responses = [
        p_model.PhotoResponse(
            photo_id=photo.photo_id,
            img_url=photo.img_url,
            caption=photo.caption,
            file_size=photo.file_size,
            content_type=photo.content_type,
            user_id=photo.user_id,
            username=photo.user.username,
            venue_id=photo.venue_id,
            venue_name=photo.venue.venue_name,
            uploaded_at=photo.uploaded_at
        )
        for photo in photos
    ]

    return {
        'photos': photo_responses,
        "has_more": len(photos) == limit,
        'next_cursor': photos[-1].photo_id if photos else None
    }

@router.get('/users/{user_id}', status_code=status.HTTP_200_OK)
def get_user_photos(db: DbSession, user_id: int, after_photo_id: Optional[int] = None, limit: int = 20):
    photos = service.get_photos_by_user(db, user_id, after_photo_id, limit)

    # Convert SQLAlchemy objects to Pydantic models
    photo_responses = [
        p_model.PhotoResponse(
            photo_id=photo.photo_id,
            img_url=photo.img_url,
            caption=photo.caption,
            file_size=photo.file_size,
            content_type=photo.content_type,
            user_id=photo.user_id,
            username=photo.user.username,
            venue_id=photo.venue_id,
            venue_name=photo.venue.venue_name,
            uploaded_at=photo.uploaded_at
        )
        for photo in photos
    ]

    return {
        'photos': photo_responses,
        "has_more": len(photos) == limit,
        'next_cursor': photos[-1].photo_id if photos else None
    }