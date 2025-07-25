
from sqlalchemy import Column, Integer, String


from .db import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)

class Entry(Base):
    __tablename__ = "entries"

    id = Column(Integer, primary_key=True, index=True)
    content = Column(String, nullable=False)
    summary = Column(String, nullable=True)
    summarized = Column(Boolean, default=False)

