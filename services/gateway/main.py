from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.routes.products import router as products_router

app = FastAPI(title="NutriScan Gateway", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)

app.include_router(products_router, prefix="/v1")


@app.get("/health")
async def health():
    return {"status": "ok", "service": "gateway"}
