import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware
from starlette.middleware.sessions import SessionMiddleware
from starlette.middleware.gzip import GZipMiddleware


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
    secret_key = os.getenv("SECRET_KEY", "your-secret-key")
    app.add_middleware(
        SessionMiddleware, 
        secret_key=secret_key, 
        https_only=os.getenv("ENVIRONMENT") == 'production',
        same_site='strict'
    )
    
    # CORS
    allowed_origins = [
        "http://localhost:3000",
        "http://127.0.0.1:3000", 
        "http://127.0.0.1:8080"
    ]
    
    if os.getenv("frontend"):
        allowed_origins.append(os.getenv('frontend'))
    
    app.add_middleware(
        CORSMiddleware,
        allow_origins=allowed_origins,
        allow_credentials=True,
        allow_methods=['GET', 'POST', 'PUT', 'DELETE'],
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