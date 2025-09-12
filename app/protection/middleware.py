import os
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware
from starlette.middleware.sessions import SessionMiddleware
from starlette.middleware.gzip import GZipMiddleware
from starlette.middleware.base import BaseHTTPMiddleware


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Add security headers to all responses."""
    
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        
        # Security headers
        response.headers["X-Frame-Options"] = "DENY"  # Prevent clickjacking
        response.headers["X-Content-Type-Options"] = "nosniff"  # Prevent MIME sniffing
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"  # Control referrer info
        response.headers["X-XSS-Protection"] = "1; mode=block"  # XSS protection
        response.headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()"  # Limit browser features
        
        # Only add CSP in production (can interfere with dev tools)
        if os.getenv("ENVIRONMENT") == "production":
            response.headers["Content-Security-Policy"] = (
                "default-src 'self'; "
                "script-src 'self'; "
                "style-src 'self' 'unsafe-inline'; "
                "img-src 'self' data: https:; "
                "font-src 'self'; "
                "connect-src 'self'"
            )
        
        return response


def setup_middleware(app: FastAPI) -> None:
    """Configure all security middleware for the FastAPI app."""
    
    # HTTPS redirect (prod only)
    #forces all HTTP requests to redirect to HTTPS (MITM protection)
    if os.getenv('ENVIRONMENT') == "production":
        app.add_middleware(HTTPSRedirectMiddleware)
    
    # Trusted Host Protection
    #Allows requests from specific domains
    allowed_hosts = os.getenv("ALLOWED_HOSTS", "localhost,127.0.0.1").split(",")
    app.add_middleware(TrustedHostMiddleware, allowed_hosts=allowed_hosts)
    
    # GZIP compression (reduces bandwith)
    #improves load time
    app.add_middleware(GZipMiddleware, minimum_size=1000)
    
    # Session middleware
    #server side sessions enabling
    secret_key = os.getenv("SECRET_KEY")
    if not secret_key:
        raise ValueError("SECRET_KEY environment variable is required")
    
    app.add_middleware(
        SessionMiddleware, 
        secret_key=secret_key, 
        https_only=os.getenv("ENVIRONMENT") == 'production',
        same_site='strict'
    )
    
    # CORS - Mobile app friendly configuration
    environment = os.getenv("ENVIRONMENT")
    
    if environment == "production":
        # Production: specific domains only
        allowed_origins = []
        if os.getenv("FRONTEND_URL"):
            allowed_origins.append(os.getenv("FRONTEND_URL"))
        # Add any additional production origins
        production_origins = os.getenv("ALLOWED_ORIGINS", "").split(",")
        allowed_origins.extend([origin.strip() for origin in production_origins if origin.strip()])
        
        if not allowed_origins:
            # Fallback to localhost for staging/testing
            allowed_origins = ["http://localhost:3000", "http://127.0.0.1:3000"]
    else:
        # Development: allow localhost and mobile development
        allowed_origins = [
            "http://localhost:3000",    # React dev
            "http://127.0.0.1:3000",   # React dev
            "http://localhost:8080",    # Vue/other dev
            "http://127.0.0.1:8080",   # Vue/other dev
            # Mobile development - allow all for easier testing
        ]
        # For mobile development, might need to allow all origins
        if os.getenv("MOBILE_DEV") == "true":
            allowed_origins = ["*"]
    
    app.add_middleware(
        CORSMiddleware,
        allow_origins=allowed_origins,
        allow_credentials=True,
        allow_methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
        allow_headers=[
            'Authorization',
            'Content-Type', 
            'X-Requested-With',
            'Accept',
            'Origin',
            'Access-Control-Request-Headers',
            'Access-Control-Request-Method',
        ],
        max_age=600,
    )
    
    # Add security headers middleware
    app.add_middleware(SecurityHeadersMiddleware)