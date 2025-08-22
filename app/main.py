from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Import all your routers
from app.auth import controller as auth_controller
from app.users import controller as users_controller
from app.venues import controller as venues_controller
from app.reviews import controller as reviews_controller
from app.photo import controller as photo_controller

# Create FastAPI app instance
app = FastAPI(
    title="Clubbies API", 
    version="0.1.0",
    description="A nightlife venue review and photo sharing API"
)

# Add CORS middleware for mobile app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register all routers
app.include_router(auth_controller.router)
app.include_router(users_controller.router)
app.include_router(venues_controller.router)
app.include_router(reviews_controller.router)
app.include_router(photo_controller.router)

# Health check endpoint
@app.get("/")
async def root():
    return {"message": "Clubbies API is running!", "version": "0.1.0"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
