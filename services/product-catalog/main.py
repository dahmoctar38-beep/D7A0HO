from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from src.services.product_service import get_product

app = FastAPI(title="NutriScan Product Catalog", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET"],
    allow_headers=["*"],
)


@app.get("/health")
async def health():
    return {"status": "ok", "service": "product-catalog"}


@app.get("/products/{barcode}")
async def product_by_barcode(barcode: str):
    product = await get_product(barcode)
    if product is None:
        raise HTTPException(status_code=404, detail=f"Product {barcode} not found")
    return product
