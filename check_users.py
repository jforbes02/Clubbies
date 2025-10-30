#!/usr/bin/env python3
"""Quick script to check users in the database"""
from app.core.database import SessionLocal
from app.models.models import User

db = SessionLocal()
try:
    users = db.query(User).order_by(User.user_id.desc()).limit(10).all()
    print(f"📊 Total users: {db.query(User).count()}")
    print("\n🔍 Last 10 users:")
    print("-" * 60)
    for user in reversed(users):
        print(f"ID: {user.user_id:3d} | {user.username:20s} | {user.email}")
finally:
    db.close()
