import os
import uvicorn
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv

# Import routers
from app.auth import controller as auth_controller
from app.users import controller as users_controller
from app.venues import controller as venues_controller
from app.reviews import controller as reviews_controller
from app.ratings import controller as ratings_controller
from app.photo import controller as photo_controller
from app.protection.middleware import setup_middleware
from app.protection.rate_limiting import limiter
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from app.core.database import engine
from app.models.models import Base

load_dotenv()

# Create database tables
Base.metadata.create_all(bind=engine)

# Create FastAPI app instance
app = FastAPI(
    title="Clubbies API", 
    version="0.1",
    description="A nightlife venue review and photo sharing API"
)

# Setup security middleware
setup_middleware(app)

# Setup rate limiting
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Register all routers
app.include_router(auth_controller.router)
app.include_router(users_controller.router)
app.include_router(venues_controller.router)
app.include_router(reviews_controller.router)
app.include_router(ratings_controller.router)
app.include_router(photo_controller.router)

# Mount static files for photo uploads
if os.getenv("ENVIRONMENT") != "production":
    import os.path
    if os.path.exists("uploads/photos"):
        app.mount("/static/photos", StaticFiles(directory="uploads/photos"), name="photos")

# Health check endpoint
@app.get("/")
async def root():
    return {"message": "Clubbies API is running!", "version": "0.1"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
