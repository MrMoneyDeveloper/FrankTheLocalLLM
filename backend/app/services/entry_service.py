from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from .. import models, schemas, dependencies

router = APIRouter(tags=["entries"], prefix="/entries")

@router.post("/", response_model=schemas.EntryRead)
def create_entry(entry: schemas.EntryCreate, db: Session = Depends(dependencies.get_db)):
    db_entry = models.Entry(content=entry.content)
    db.add(db_entry)
    db.commit()
    db.refresh(db_entry)
    return db_entry

@router.get("/", response_model=list[schemas.EntryRead])
def list_entries(db: Session = Depends(dependencies.get_db)):
    return db.query(models.Entry).all()
