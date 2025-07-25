from pydantic import BaseModel

class UserBase(BaseModel):
    username: str

class UserCreate(UserBase):
    password: str

class UserRead(UserBase):
    id: int

    class Config:
        orm_mode = True


class EntryBase(BaseModel):
    content: str


class EntryCreate(EntryBase):
    pass


class EntryRead(EntryBase):
    id: int
    summary: str | None = None
    summarized: bool

    class Config:
        orm_mode = True

