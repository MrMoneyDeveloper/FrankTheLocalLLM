from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from .. import models, schemas, security, dependencies
from . import UnitOfWork, get_uow

router = APIRouter(tags=["auth"], prefix="/auth")


class AuthService:
    def __init__(self, uow: UnitOfWork):
        self.uow = uow
        self.db: Session = uow.db

    def create(self, data: schemas.UserCreate) -> models.User:
        existing = (
            self.db.query(models.User)
            .filter(models.User.username == data.username)
            .first()
        )
        if existing:
            raise HTTPException(status_code=400, detail="Username already registered")
        hashed = security.get_password_hash(data.password)
        user = models.User(username=data.username, hashed_password=hashed)
        self.uow.add(user)
        return user

    def read(self, username: str) -> models.User | None:
        return self.db.query(models.User).filter(models.User.username == username).first()

    def update(self, *args, **kwargs):  # pragma: no cover - unused
        raise NotImplementedError

    def delete(self, *args, **kwargs):  # pragma: no cover - unused
        raise NotImplementedError

    def login(self, data: schemas.UserCreate) -> dict:
        user = self.read(data.username)
        if not user or not security.verify_password(data.password, user.hashed_password):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        token = security.create_access_token({"sub": user.username})
        return {"access_token": token, "token_type": "bearer"}


def _get_uow(db: Session = Depends(dependencies.get_db)):
    yield from get_uow(db)


def get_service(uow: UnitOfWork = Depends(_get_uow)) -> AuthService:
    return AuthService(uow)


@router.post("/register", response_model=schemas.UserRead)
def register(user: schemas.UserCreate, service: AuthService = Depends(get_service)):
    result = service.create(user)
    service.uow.flush()
    return result


@router.post("/login")
def login(user: schemas.UserCreate, service: AuthService = Depends(get_service)):
    return service.login(user)
