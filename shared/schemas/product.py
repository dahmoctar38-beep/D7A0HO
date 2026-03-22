from __future__ import annotations
from pydantic import BaseModel
from typing import Optional


class NutritionFacts(BaseModel):
    calories: float
    protein: float
    carbohydrates: float
    sugar: float
    fat: float
    saturated_fat: float
    fiber: float
    sodium: float


class Product(BaseModel):
    barcode: str
    name: str
    brand: str
    image_url: Optional[str] = None
    nutrition: NutritionFacts
    ingredients: list[str]
    allergens: list[str]
    nutriscore: Optional[str] = None
