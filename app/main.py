from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
app = FastAPI(title="Clubbies API", version="1.0")


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/hello/{name}")
async def say_hello(name: str):
    return {"message": f"Hello {name}"}
