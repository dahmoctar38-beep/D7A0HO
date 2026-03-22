import pytest
import httpx
import respx
from src.services.product_service import get_product, _SEED


@pytest.mark.asyncio
async def test_seed_product_found():
    """Known barcode returns product from seed when OFF is mocked to 404."""
    with respx.mock:
        respx.get("https://world.openfoodfacts.org/api/v2/product/5449000000996.json").mock(
            return_value=httpx.Response(404)
        )
        product = await get_product("5449000000996")
    assert product is not None
    assert product.barcode == "5449000000996"
    assert product.name == "Coca-Cola Original"
    assert product.nutrition.sugar == 10.6


@pytest.mark.asyncio
async def test_seed_product_not_found():
    """Unknown barcode returns None when OFF also has nothing."""
    with respx.mock:
        respx.get("https://world.openfoodfacts.org/api/v2/product/0000000000000.json").mock(
            return_value=httpx.Response(404)
        )
        product = await get_product("0000000000000")
    assert product is None


@pytest.mark.asyncio
async def test_all_seed_products_have_nutrition():
    """Every seed product has non-negative calorie values (uses seed directly)."""
    for barcode, product in _SEED.items():
        assert product.nutrition.calories >= 0
        assert product.barcode == barcode


@pytest.mark.asyncio
async def test_off_success_overrides_seed():
    """When OFF returns a valid product, it takes priority over seed."""
    barcode = "5449000000996"
    with respx.mock:
        respx.get(f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json").mock(
            return_value=httpx.Response(
                200,
                json={
                    "status": 1,
                    "product": {
                        "product_name_en": "Coke FROM OFF",
                        "brands": "Coca-Cola",
                        "nutriments": {
                            "energy-kcal_100g": 45,
                            "proteins_100g": 0,
                            "carbohydrates_100g": 11,
                            "sugars_100g": 11,
                            "fat_100g": 0,
                            "saturated-fat_100g": 0,
                            "fiber_100g": 0,
                            "sodium_100g": 0,
                        },
                        "allergens": "",
                        "ingredients_text_en": "carbonated water, sugar",
                        "nutriscore_grade": "e",
                    },
                },
            )
        )
        product = await get_product(barcode)
    assert product is not None
    assert product.name == "Coke FROM OFF"
    assert product.nutriscore == "E"


@pytest.mark.asyncio
async def test_off_failure_falls_back_to_seed():
    """When OFF returns 503, seed data is used."""
    barcode = "5449000000996"
    with respx.mock:
        respx.get(f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json").mock(
            return_value=httpx.Response(503)
        )
        product = await get_product(barcode)
    assert product is not None
    assert product.name == "Coca-Cola Original"
