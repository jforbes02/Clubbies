import os
from datetime import datetime

from sqlalchemy.orm import Session
from . import p_model
from fastapi import UploadFile, HTTPException
from app.models.models import Photo, Venue, User
import logging
import uuid

async def create_photo(db: Session, photo_data: p_model.PhotoBase, user_id: int, file: UploadFile) -> Photo:
    try:
        #Validate venue
        venue = db.query(Venue).filter(Venue.venue_id == photo_data.venue_id).first()
        if not venue:
            logging.error(f"Venue {photo_data.venue_id} not found")
            raise HTTPException(status_code=404, detail="Venue not found")

        #validate user
        user = db.query(User).filter(User.user_id == user_id).first()
        if not user:
            logging.error(f"User {user_id} not found")
            raise HTTPException(status_code=404, detail="User not found")

        #validate file type
        if not file.content_type.startswith("image/"):
            logging.error(f"File {file.content_type} not supported")
            raise HTTPException(status_code=404, detail="File not supported")

        #unique filename
        file_extension = file.filename.split('.')[-1] if '.' in file.filename else 'jpg'
        unique_filename = f"{uuid.uuid4()}.{file_extension}"

        #filepath
        upload_dir = "uploads/photos"
        user_dir = os.path.join(upload_dir, str(user_id))  # Convert user_id to string
        os.makedirs(user_dir, exist_ok=True)
        file_path = os.path.join(upload_dir, unique_filename)
        img_url = f"/static/photos/{user_id}/{unique_filename}"

        #save file
        file_content = await file.read()
        if len(file_content) > 10 * 1024 * 1024:
            raise HTTPException(status_code=413, detail="File too large")
        with open(file_path, 'wb') as buffer:
            buffer.write(file_content)

        #make db record
        photo = Photo(
            img_url=img_url,
            caption=photo_data.caption,
            venue_id=photo_data.venue_id,
            user_id=user_id,
            file_size=len(file_content),
            uploaded_at=datetime.utcnow()
        )
        db.add(photo)
        db.commit()
        db.refresh(photo)

        return photo
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to upload photo: {str(e)}")

def get_photo_by_id(db: Session, id: int) -> Photo:
    photo = db.query(Photo).get(id)
    if not photo:
        raise HTTPException(status_code=404, detail="Photo not found")
    return photo

def get_photos_by_venue(db: Session, venue_id: int, after_photo_id: int = None, limit: int = 20) -> list[Photo]:
    try:
        venue = db.query(Venue).filter(Venue.venue_id == venue_id).first()
        if not venue:
            raise HTTPException(status_code=404, detail="Venue not found")
            
        query = db.query(Photo).filter(Photo.venue_id == venue_id)
        
        if after_photo_id:
            query = query.filter(Photo.photo_id > after_photo_id)
            
        photos = query.order_by(Photo.photo_id.asc()).limit(limit).all()
        
        logging.info(f"Retrieved {len(photos)} photos for venue {venue_id}")
        return photos
        
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Error fetching photos for venue {venue_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")

def get_photos_by_user(db: Session, user_id: int, after_photo_id: int = None, limit: int = 20) -> list[Photo]:
    try:
        user = db.query(User).filter(User.user_id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
            
        query = db.query(Photo).filter(Photo.user_id == user_id)
        
        if after_photo_id:
            query = query.filter(Photo.photo_id > after_photo_id)
            
        photos = query.order_by(Photo.photo_id.asc()).limit(limit).all()
        
        logging.info(f"Retrieved {len(photos)} photos for user {user_id}")
        return photos
        
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Error fetching photos for user {user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")

def delete_photo(db: Session, photo_id: int) -> None:
    try:
        photo = get_photo_by_id(db, photo_id)
        db.delete(photo)
        db.commit()
        logging.info(f"Deleted photo {photo_id}")
    except HTTPException as e:
        logging.error(f"Failed to delete photo: {str(e)}")
        raise e

def change_photo_caption(db: Session, photo_id: int, caption: str):
    try:
        photo = get_photo_by_id(db, photo_id)
        if not photo:
            raise HTTPException(status_code=404, detail="Photo not found")
        photo.caption = caption
        db.commit()
        db.refresh(photo)
    except HTTPException as e:
        logging.error(f"Failed to change photo caption: {str(e)}")
        raise e