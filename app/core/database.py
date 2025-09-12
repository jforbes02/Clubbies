#connecting to postgresql
from fastapi import Depends
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker
import os
from dotenv import load_dotenv
from typing import Annotated
load_dotenv()

#Database connection url
DATABASE_URL = os.environ.get("DATABASE_URL")
if not DATABASE_URL:
    raise ValueError("DATABASE_URL is not set")
# creates database engine(translates python->sql)
engine = create_engine(DATABASE_URL)

#creates sessions for changing the database per each API request
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

#Parent class
class Base(DeclarativeBase):
    pass

#gets database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


DbSession = Annotated[Session, Depends(get_db)]