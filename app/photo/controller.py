from typing import Optional

from fastapi import APIRouter, UploadFile, File, Form
from starlette import status
from app.core.database import DbSession
from . import p_model
from . import service
router = APIRouter(
    prefix='/photo',
    tags=['photo']
)


# noinspection PyTypeHints
@router.post("/upload", status_code=status.HTTP_200_OK)
async def upload_photo(db: DbSession,
                       current_user_id: int,
                       file: UploadFile = File(...),
                       venue_id: int = Form(...),
                       caption: Optional[str] = Form(None)):
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
    )


# noinspection PyTypeHints
@router.delete("/delete-photo", status_code=status.HTTP_204_NO_CONTENT)
def delete_photo(db: DbSession, photo_id: int):
    service.delete_photo(db, photo_id)


# noinspection PyTypeHints
@router.put("/update-photo", status_code=status.HTTP_204_NO_CONTENT)
async def update_photo(db: DbSession, photo_id: int, new_caption: str):
    service.change_photo_caption(db, photo_id, new_caption)