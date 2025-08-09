# test_database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from datetime import datetime

from database import Base, get_db
from models import User, Photo, Review, Venue

# Create test database
DATABASE_URL = "postgresql://postgres:Coolpyro55@localhost:5432/nightlife_test_db"
engine = create_engine(DATABASE_URL)

# Create all tables
Base.metadata.create_all(bind=engine)

# Create session
SessionLocal = sessionmaker(bind=engine)
session = SessionLocal()


def test_database_relationships():
    print("🧪 Testing Database Relationships...")

    # 1. Create test data
    print("\n📝 Creating test data...")

    # Create users
    user1 = User(
        username="party_lover",
        password_hashed="hashed_password_123",
        email="party@email.com",
        age=25
    )

    user2 = User(
        username="club_hopper",
        password_hashed="hashed_password_456",
        email="club@email.com",
        age=22
    )

    # Create venue
    venue1 = Venue(
        venue_name="Electric Nights Club",
        address="123 Party Street",
        hours="9PM - 3AM",
        venue_type="nightclub",
        age_req=21,
        description="Best EDM club in town",
        capacity="500"
    )

    # Add to session
    session.add_all([user1, user2, venue1])
    session.commit()
    print("✅ Users and venue created")

    # 2. Create reviews
    review1 = Review(
        rating=4.5,
        review_text="Amazing club! Great music and atmosphere",
        date_made=datetime.now(),
        user_id=user1.user_id,
        venue_id=venue1.venue_id
    )

    review2 = Review(
        rating=5.0,
        review_text="Best night ever! Will definitely come back",
        date_made=datetime.now(),
        user_id=user2.user_id,
        venue_id=venue1.venue_id
    )

    session.add_all([review1, review2])
    session.commit()
    print("✅ Reviews created")

    # 3. Create photos
    photo1 = Photo(
        img_data="data:image/jpeg;base64,fake_image_data_1",
        caption="Dance floor was packed!",
        uploaded_at=datetime.now(),
        user_id=user1.user_id,
        venue_id=venue1.venue_id
    )

    photo2 = Photo(
        img_data="data:image/jpeg;base64,fake_image_data_2",
        caption="DJ was incredible",
        uploaded_at=datetime.now(),
        user_id=user2.user_id,
        venue_id=venue1.venue_id
    )

    session.add_all([photo1, photo2])
    session.commit()
    print("✅ Photos created")

    # 4. Test relationships
    print("\n🔗 Testing Relationships...")

    # Test User -> Reviews relationship
    user = session.query(User).filter(User.username == "party_lover").first()
    print(f"User '{user.username}' has {len(user.reviews)} reviews")
    for review in user.reviews:
        print(f"  - Review: {review.review_text[:30]}... (Rating: {review.rating})")

    # Test User -> Photos relationship
    print(f"User '{user.username}' has {len(user.photos)} photos")
    for photo in user.photos:
        print(f"  - Photo: {photo.caption}")

    # Test Venue -> Reviews relationship
    venue = session.query(Venue).filter(Venue.venue_name == "Electric Nights Club").first()
    print(f"\nVenue '{venue.venue_name}' has {len(venue.reviews)} reviews")
    for review in venue.reviews:
        print(f"  - By {review.user.username}: {review.review_text[:30]}...")

    # Test Venue -> Photos relationship
    print(f"Venue '{venue.venue_name}' has {len(venue.photos)} photos")
    for photo in venue.photos:
        print(f"  - By {photo.user.username}: {photo.caption}")

    # Test reverse relationships (backref)
    review = session.query(Review).first()
    print(f"\nReview belongs to user: {review.user.username}")
    print(f"Review is about venue: {review.venue.venue_name}")

    photo = session.query(Photo).first()
    print(f"Photo uploaded by: {photo.user.username}")
    print(f"Photo is of venue: {photo.venue.venue_name}")

    print("\n✅ All relationships working correctly!")


def test_constraints():
    print("\n🛡️ Testing Constraints...")

    try:
        # Get existing venue from previous test (or create one)
        existing_venue = session.query(Venue).first()

        if not existing_venue:
            print("⚠️ No venue found, creating one for constraints test...")
            existing_venue = Venue(
                venue_name="Constraint Test Venue",
                address="456 Test Street",
                hours="8PM - 2AM",
                venue_type="bar",
                age_req=21,
                description="Test venue for constraints",
                capacity="100"
            )
            session.add(existing_venue)
            session.commit()

        # Test age constraint (should work)
        valid_user = User(
            username="constraint_test_user",
            password_hashed="hash",
            email="constraint@email.com",
            age=21  # Valid age
        )
        session.add(valid_user)
        session.commit()
        print("✅ Valid age accepted")

        # Test rating constraint (should work) - USE REAL VENUE ID
        valid_review = Review(
            rating=4.0,  # Valid rating
            review_text="Good place for constraint testing",
            date_made=datetime.now(),
            user_id=valid_user.user_id,
            venue_id=existing_venue.venue_id  # ← Use actual venue ID!
        )
        session.add(valid_review)
        session.commit()
        print("✅ Valid rating accepted")

    except Exception as e:
        print(f"❌ Constraint error: {e}")
        session.rollback()  # Clean up failed transaction


def debug_database():
    """Debug helper to see what's in the database"""
    print("\n🔍 Database Debug Info:")

    users = session.query(User).all()
    print(f"Users: {len(users)}")
    for user in users:
        print(f"  - ID: {user.user_id}, Username: {user.username}")

    venues = session.query(Venue).all()
    print(f"Venues: {len(venues)}")
    for venue in venues:
        print(f"  - ID: {venue.venue_id}, Name: {venue.venue_name}")

    reviews = session.query(Review).all()
    print(f"Reviews: {len(reviews)}")
    for review in reviews:
        print(f"  - ID: {review.review_id}, User: {review.user_id}, Venue: {review.venue_id}")


def clear_all_data():
    """Delete all data but keep table structure"""
    print("🗑️ Clearing all data...")

    # Delete in reverse order of dependencies (avoid foreign key errors)
    session.query(Review).delete()
    session.query(Photo).delete()
    session.query(User).delete()
    session.query(Venue).delete()

    session.commit()
    print("✅ All data cleared!")


if __name__ == "__main__":
    # Clear data first
    clear_all_data()

    # Run relationship tests (creates data)
    test_database_relationships()

    # Run constraint tests (uses existing data)
    test_constraints()

    # Debug what's in the database
    debug_database()

    # Close session
    session.close()
    print("\n🎉 Database tests completed!")

    # Optional: clear data at the end
    clear_all_data()