import os
from datetime import datetime, timezone
import cloudinary
import cloudinary.uploader
from sqlalchemy.orm import Session, joinedload
from . import p_model
from fastapi import UploadFile, HTTPException
from app.models.models import Photo, Venue, User
import logging
import uuid
from typing import List
from sqlalchemy.exc import IntegrityError
from PIL import Image
import io

async def create_photo(db: Session, photo_data: p_model.PhotoBase, user_id: int, file: UploadFile) -> Photo:
    try:
        #validate file type - accept any image or octet-stream (iOS image_picker sends this)
        valid_content_types = file.content_type and (
            file.content_type.startswith("image/") or
            file.content_type == "application/octet-stream"
        )
        if not valid_content_types:
            logging.error(f"Invalid content type: {file.content_type} for file: {file.filename}")
            raise HTTPException(status_code=400, detail="File must be an image")

        #accept HEIC/HEIF from iPhones
        extension_types = {'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'}
        file_extension = file.filename.split('.')[-1].lower() if '.' in file.filename else 'jpg'

        #convert HEIC to JPG (image_picker already does this on iOS)
        if file_extension in {'heic', 'heif'}:
            file_extension = 'jpg'
        elif file_extension not in extension_types:
            logging.error(f"Unsupported extension: {file_extension} for file: {file.filename}")
            raise HTTPException(status_code=400, detail=f"File type .{file_extension} not supported. Allowed: jpg, jpeg, png, webp")

        unique_filename = f"{uuid.uuid4()}.{file_extension}"

        # Read file content
        file_content = await file.read()

        # Validate file size (10MB limit)
        if len(file_content) > 10 * 1024 * 1024:
            raise HTTPException(status_code=413, detail="File too large. Maximum size is 10MB")
        try:
            Image.open(io.BytesIO(file_content)).verify()
        except Exception as img_error:
            logging.error(f"Image validation failed for file: {file.filename}, error: {str(img_error)}")
            raise HTTPException(status_code=400, detail="Uploaded file is not a valid image")
        # Upload to Cloudinary
        cloudinary_public_id = None
        try:
            upload_res = cloudinary.uploader.upload(
                file_content,
                folder=f"clubbies/venues/{photo_data.venue_id}",
                public_id=unique_filename.split('.')[0],
                overwrite=False,
                resource_type="image",
                transformation={"quality":"auto","fetch_format":"auto"},               
            )
            img_url = upload_res.get("secure_url")
            cloudinary_public_id = upload_res.get("public_id")

            if not img_url:
                raise HTTPException(status_code=500, detail="Cloudinary upload failed - no URL returned")

        except Exception as e:
            logging.error(f"Cloudinary upload failed: {str(e)}")
            raise HTTPException(status_code=500, detail=f"Failed to upload to Cloudinary: {str(e)}")

        # Create database record
        try:
            photo = Photo(
                img_url=img_url,
                caption=photo_data.caption,
                venue_id=photo_data.venue_id,
                user_id=user_id,
                file_size=len(file_content),
                content_type=file.content_type,
                uploaded_at=datetime.now(timezone.utc),
            )
            db.add(photo)
            db.commit()
            db.refresh(photo)

        except IntegrityError as e:
            # Foreign key constraint violation - clean up Cloudinary upload
            db.rollback()
            if cloudinary_public_id:
                try:
                    cloudinary.uploader.destroy(cloudinary_public_id)
                    logging.info(f"Cleaned up Cloudinary upload: {cloudinary_public_id}")
                except Exception as cleanup_error:
                    logging.error(f"Failed to cleanup Cloudinary upload: {cleanup_error}")

            if "venue_id" in str(e):
                raise HTTPException(status_code=404, detail="Venue not found")
            else:
                raise HTTPException(status_code=400, detail="Invalid data provided")

        except Exception as e:
            # Other database error - clean up Cloudinary upload
            db.rollback()
            if cloudinary_public_id:
                try:
                    cloudinary.uploader.destroy(cloudinary_public_id)
                    logging.info(f"Cleaned up Cloudinary upload: {cloudinary_public_id}")
                except Exception as cleanup_error:
                    logging.error(f"Failed to cleanup Cloudinary upload: {cleanup_error}")
            raise HTTPException(status_code=500, detail="Failed to save photo to database")

        return photo

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logging.error(f"Unexpected error in create_photo: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to upload photo: {str(e)}")

def get_photo_by_id(db: Session, picture_id: int) -> Photo:
    photo = db.query(Photo).get(picture_id)
    if not photo:
        raise HTTPException(status_code=404, detail="Photo not found")
    return photo


# noinspection PyTypeChecker
def get_photos_by_venue(db: Session, venue_id: int, after_photo_id: int = None, limit: int = 20) -> List[Photo]:
    try:
        venue = db.query(Venue).filter(Venue.venue_id == venue_id).first()
        if not venue:
            raise HTTPException(status_code=404, detail="Venue not found")
            
        query = db.query(Photo).options(joinedload(Photo.user), joinedload(Photo.venue)).filter(Photo.venue_id == venue_id)

        if after_photo_id:
            query = query.filter(Photo.photo_id < after_photo_id)

        photos = query.order_by(Photo.photo_id.desc()).limit(limit).all()
        
        logging.info(f"Retrieved {len(photos)} photos for venue {venue_id}")
        return photos

    except Exception as e:
        logging.error(f"Error fetching photos for venue {venue_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")


# noinspection PyTypeChecker
def get_photos_by_user(db: Session, user_id: int, after_photo_id: int = None, limit: int = 20) -> List[Photo]:
    try:
        user = db.query(User).filter(User.user_id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
            
        query = db.query(Photo).filter(Photo.user_id == user_id)

        if after_photo_id:
            query = query.filter(Photo.photo_id < after_photo_id)

        photos = query.order_by(Photo.photo_id.desc()).limit(limit).all()
        
        logging.info(f"Retrieved {len(photos)} photos for user {user_id}")
        return photos
        
    except HTTPException:
        raise HTTPException(status_code=500, detail="Internal server error")
    except Exception as e:
        logging.error(f"Error fetching photos for user {user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")

def delete_photo(db: Session, photo_id: int) -> None:
    try:
        photo = get_photo_by_id(db, photo_id)

        # Extract public_id from Cloudinary URL
        # URL format: https://res.cloudinary.com/{cloud_name}/image/upload/{version}/{public_id}.{ext}
        try:
            url_parts = photo.img_url.split('/')
            # Find 'upload' in the URL and get everything after it
            upload_index = url_parts.index('upload')
            # public_id is everything after 'upload' (excluding version if present)
            public_id_parts = url_parts[upload_index + 1:]

            # Skip version number if present (starts with 'v' followed by digits)
            if public_id_parts and public_id_parts[0].startswith('v') and public_id_parts[0][1:].isdigit():
                public_id_parts = public_id_parts[1:]

            # Join remaining parts and remove file extension
            public_id = '/'.join(public_id_parts).rsplit('.', 1)[0]

            # Delete from Cloudinary
            cloudinary.uploader.destroy(public_id)
            logging.info(f"Deleted photo from Cloudinary: {public_id}")

        except Exception as cloudinary_error:
            # Log error but continue with database deletion
            logging.error(f"Failed to delete from Cloudinary: {cloudinary_error}")

        # Delete from database
        db.delete(photo)
        db.commit()
        logging.info(f"Deleted photo {photo_id} from database")

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logging.error(f"Failed to delete photo: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to delete photo")


def change_photo_caption(db: Session, photo_id: int, caption: str):
    try:
        photo = get_photo_by_id(db, photo_id)
        photo.caption = caption
        db.commit()
        db.refresh(photo)
    except HTTPException as e:
        logging.error(f"Failed to change photo caption: {str(e)}")
        raise e