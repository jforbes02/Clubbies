#connecting to postgresql
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import sessionmaker

#Database connection url
DATABASE_URL = "postgresql://postgres:Coolpyro55@localhost:5432/clubbies_db"

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