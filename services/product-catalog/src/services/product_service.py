"""
Product lookup: tries Open Food Facts first, falls back to local seed data.
"""
from __future__ import annotations
import httpx
import logging
from typing import Optional
from ..models.product import Product, NutritionFacts

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Seed data — used when OFF doesn't have the product
# ---------------------------------------------------------------------------
_SEED: dict[str, Product] = {
    "6281006530015": Product(
        barcode="6281006530015",
        name="Almarai Full Fat Milk",
        brand="Almarai",
        nutriscore="B",
        nutrition=NutritionFacts(
            calories=62, protein=3.2, carbohydrates=4.8,
            sugar=4.8, fat=3.3, saturated_fat=2.1, fiber=0, sodium=0.04,
        ),
        ingredients=["Whole milk"],
        allergens=["Milk"],
    ),
    "6281034000011": Product(
        barcode="6281034000011",
        name="Chips Oman Classic",
        brand="Oman Chips",
        nutriscore="D",
        nutrition=NutritionFacts(
            calories=536, protein=6.5, carbohydrates=52,
            sugar=0.5, fat=34, saturated_fat=14, fiber=3.5, sodium=0.9,
        ),
        ingredients=["Potatoes", "Palm oil", "Salt", "Flavor enhancer (E621)"],
        allergens=[],
    ),
    "5449000000996": Product(
        barcode="5449000000996",
        name="Coca-Cola Original",
        brand="Coca-Cola",
        nutriscore="E",
        nutrition=NutritionFacts(
            calories=42, protein=0, carbohydrates=10.6,
            sugar=10.6, fat=0, saturated_fat=0, fiber=0, sodium=0.01,
        ),
        ingredients=[
            "Carbonated water", "Sugar", "Caramel color (E150d)",
            "Phosphoric acid", "Natural flavors", "Caffeine",
        ],
        allergens=[],
    ),
    "6221012850014": Product(
        barcode="6221012850014",
        name="Quaker Oats",
        brand="Quaker",
        nutriscore="A",
        nutrition=NutritionFacts(
            calories=367, protein=13, carbohydrates=58,
            sugar=1.1, fat=6.9, saturated_fat=1.3, fiber=10, sodium=0.004,
        ),
        ingredients=["100% whole grain oats"],
        allergens=["Gluten"],
    ),
    "8712100325977": Product(
        barcode="8712100325977",
        name="Snickers Bar",
        brand="Mars",
        nutriscore="E",
        nutrition=NutritionFacts(
            calories=488, protein=8.2, carbohydrates=60,
            sugar=49, fat=23, saturated_fat=8.8, fiber=1.6, sodium=0.23,
        ),
        ingredients=[
            "Milk chocolate", "Sugar", "Peanuts", "Glucose syrup",
            "Skimmed milk powder", "Palm fat", "Butter",
        ],
        allergens=["Milk", "Peanuts", "Soy"],
    ),
}

OFF_BASE = "https://world.openfoodfacts.org/api/v2/product"


async def get_product(barcode: str) -> Optional[Product]:
    # 1. Try OFF
    try:
        product = await _fetch_from_off(barcode)
        if product:
            return product
    except Exception as exc:
        logger.warning("OFF lookup failed for %s: %s", barcode, exc)

    # 2. Fall back to seed
    return _SEED.get(barcode)


async def _fetch_from_off(barcode: str) -> Optional[Product]:
    url = f"{OFF_BASE}/{barcode}.json"
    async with httpx.AsyncClient(timeout=5.0) as client:
        response = await client.get(url)

    if response.status_code != 200:
        return None

    data = response.json()
    if data.get("status") != 1:
        return None

    p = data.get("product", {})
    nutriments = p.get("nutriments", {})

    def _n(key: str, fallback: float = 0.0) -> float:
        return float(nutriments.get(f"{key}_100g", nutriments.get(key, fallback)))

    allergens_raw: str = p.get("allergens", "")
    allergens = [a.strip().replace("en:", "").title()
                 for a in allergens_raw.split(",") if a.strip()]

    ingredients_text: str = p.get("ingredients_text_en") or p.get("ingredients_text", "")
    ingredients = [i.strip() for i in ingredients_text.split(",") if i.strip()][:20]

    return Product(
        barcode=barcode,
        name=p.get("product_name_en") or p.get("product_name", "Unknown"),
        brand=p.get("brands", "Unknown"),
        image_url=p.get("image_front_url"),
        nutrition=NutritionFacts(
            calories=_n("energy-kcal"),
            protein=_n("proteins"),
            carbohydrates=_n("carbohydrates"),
            sugar=_n("sugars"),
            fat=_n("fat"),
            saturated_fat=_n("saturated-fat"),
            fiber=_n("fiber"),
            sodium=_n("sodium"),
        ),
        ingredients=ingredients,
        allergens=allergens,
        nutriscore=p.get("nutriscore_grade", "").upper() or None,
    )
