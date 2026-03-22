import httpx
import os
from fastapi import APIRouter, HTTPException

router = APIRouter()

CATALOG_URL = os.getenv("PRODUCT_CATALOG_URL", "http://product-catalog:8001")
AI_URL = os.getenv("AI_NUTRITION_URL", "http://ai-nutrition:8002")


@router.get("/products/{barcode}")
async def get_product(barcode: str):
    async with httpx.AsyncClient(timeout=10.0) as client:
        resp = await client.get(f"{CATALOG_URL}/products/{barcode}")
    if resp.status_code == 404:
        raise HTTPException(status_code=404, detail=f"Product {barcode} not found")
    if resp.status_code != 200:
        raise HTTPException(status_code=502, detail="Product catalog error")
    return resp.json()


@router.get("/analysis/{barcode}")
async def get_analysis(barcode: str):
    # Fetch product first
    async with httpx.AsyncClient(timeout=10.0) as client:
        product_resp = await client.get(f"{CATALOG_URL}/products/{barcode}")

    if product_resp.status_code == 404:
        raise HTTPException(status_code=404, detail=f"Product {barcode} not found")
    if product_resp.status_code != 200:
        raise HTTPException(status_code=502, detail="Product catalog error")

    product_data = product_resp.json()

    # Send to AI nutrition service
    async with httpx.AsyncClient(timeout=15.0) as client:
        analysis_resp = await client.post(f"{AI_URL}/analysis", json=product_data)

    if analysis_resp.status_code != 200:
        raise HTTPException(status_code=502, detail="AI nutrition service error")

    return analysis_resp.json()
