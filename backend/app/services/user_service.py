from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from .. import schemas, dependencies, models
from . import UnitOfWork, get_uow

router = APIRouter(tags=["user"], prefix="/user")


class UserService:
    def __init__(self, uow: UnitOfWork):
        self.uow = uow
        self.db: Session = uow.db

    def read(self, user: models.User) -> models.User:
        return user

    def create(self, *args, **kwargs):  # pragma: no cover - unused
        raise NotImplementedError

    def update(self, *args, **kwargs):  # pragma: no cover - unused
        raise NotImplementedError

    def delete(self, *args, **kwargs):  # pragma: no cover - unused
        raise NotImplementedError


def _get_uow(db: Session = Depends(dependencies.get_db)):
    yield from get_uow(db)


def get_service(uow: UnitOfWork = Depends(_get_uow)) -> UserService:
    return UserService(uow)


@router.get("/me", response_model=schemas.UserRead)
def read_me(
    current_user: models.User = Depends(dependencies.get_current_user),
    service: UserService = Depends(get_service),
):
    return service.read(current_user)
