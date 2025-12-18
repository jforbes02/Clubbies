import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.core.database import engine, SessionLocal
from app.models.models import User, Venue, Review, Photo, VenueType, VenueCapacity
from app.auth.service import get_password_hash
from datetime import datetime
import random


def seed_database():
    db = SessionLocal()

    try:
        # Clear existing data (optional)
        print("Clearing existing data...")
        db.query(Photo).delete()
        db.query(Review).delete()
        db.query(Venue).delete()
        db.query(User).delete()
        db.commit()

        # Create Users
        print("Creating users...")
        users = [
            User(
                username="admin",
                email="admin@clubbies.com",
                password_hashed=get_password_hash("admin123"),
                age=30,
                role = "admin"
            ),
            User(
                username="john_doe",
                email="john@example.com",
                password_hashed=get_password_hash("password123"),
                age=25
            ),
            User(
                username="jane_smith",
                email="jane@example.com",
                password_hashed=get_password_hash("password123"),
                age=22
            ),
        ]
        db.add_all(users)
        db.commit()

        # Create Venues
        print("Creating venues...")
        venues = [
            Venue(
                venue_name="Electric Skyline",
                address="456 Sunset Blvd, Miami, FL",
                hours="10PM-5AM",
                venue_type=[VenueType.NIGHTCLUB, VenueType.ROOFTOP],
                age_req=21,
                capacity=VenueCapacity.LARGE,
                price=50,
                description="Miami's premier rooftop nightclub with ocean views"
            ),
            Venue(
                venue_name="The Jazz Corner",
                address="789 Music Ave, New Orleans, LA",
                hours="7PM-2AM",
                venue_type=[VenueType.JAZZCLUB, VenueType.BAR],
                age_req=21,
                capacity=VenueCapacity.SMALL,
                price=20,
                description="Intimate jazz club with live performances nightly"
            ),
            Venue(
                venue_name="Campus Pub",
                address="321 University Way, Boston, MA",
                hours="4PM-1AM",
                venue_type=[VenueType.COLLEGE, VenueType.SPORTSBAR],
                age_req=18,
                capacity=VenueCapacity.MEDIUM,
                price=10,
                description="Student-friendly bar with cheap drinks and big screens"
            ),
        ]
        db.add_all(venues)
        db.commit()

        # Create Reviews
        print("Creating reviews...")
        for venue in venues:
            for user in users[:2]:  # First 2 users review each venue
                review = Review(
                    user_id=user.user_id,
                    venue_id=venue.venue_id,
                    rating=random.uniform(3.5, 5.0),
                    review_text=f"Great experience at {venue.venue_name}!",
                    created_at=datetime.now()
                )
                db.add(review)
        db.commit()

        print("✅ Database seeded successfully!")

    except Exception as e:
        print(f"❌ Error seeding database: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    seed_database()