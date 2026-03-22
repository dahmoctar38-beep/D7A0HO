from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from src.models.product import Product
from src.agents.nutrition_agent import analyze

app = FastAPI(title="NutriScan AI Nutrition", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)


@app.get("/health")
async def health():
    return {"status": "ok", "service": "ai-nutrition"}


@app.post("/analysis")
async def analyze_product(product: Product):
    try:
        result = await analyze(product)
        return result
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))
