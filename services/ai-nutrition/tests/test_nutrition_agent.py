import pytest
from src.agents.nutrition_agent import _score, _verdict, _diabetic_risk, _highlights, _concerns
from src.models.product import NutritionFacts
from src.models.analysis import HealthVerdict, RiskLevel


def _n(**kwargs) -> NutritionFacts:
    defaults = dict(calories=100, protein=5, carbohydrates=20,
                    sugar=5, fat=3, saturated_fat=1, fiber=2, sodium=0.1)
    defaults.update(kwargs)
    return NutritionFacts(**defaults)


class TestScoring:
    def test_neutral_product_scores_100(self):
        n = _n(sugar=0, saturated_fat=0, sodium=0, calories=200, protein=0, fiber=0)
        assert _score(n) == 100

    def test_high_sugar_penalty(self):
        assert _score(_n(sugar=25)) < _score(_n(sugar=5))

    def test_empty_calorie_penalty(self):
        """High sugar + zero protein + zero fiber should be penalised."""
        cola = _n(sugar=10.6, protein=0, fiber=0, saturated_fat=0, sodium=0, calories=42)
        oats = _n(sugar=1.1, protein=13, fiber=10, saturated_fat=1.3, sodium=0.004, calories=367)
        assert _score(cola) < _score(oats)

    def test_coca_cola_not_excellent(self):
        cola = _n(sugar=10.6, protein=0, fiber=0, saturated_fat=0, sodium=0, calories=42)
        assert _verdict(_score(cola)) != HealthVerdict.excellent

    def test_quaker_oats_good_or_better(self):
        oats = _n(sugar=1.1, protein=13, fiber=10, saturated_fat=1.3, sodium=0.004, calories=367)
        assert _verdict(_score(oats)) in (HealthVerdict.excellent, HealthVerdict.good)

    def test_snickers_poor_or_avoid(self):
        snickers = _n(sugar=49, protein=8.2, fiber=1.6, saturated_fat=8.8, sodium=0.23, calories=488)
        assert _verdict(_score(snickers)) in (HealthVerdict.poor, HealthVerdict.avoid)

    def test_score_clamped_0_to_100(self):
        extreme = _n(sugar=100, saturated_fat=50, sodium=5, calories=900, protein=0, fiber=0)
        assert 0 <= _score(extreme) <= 100


class TestDiabeticRisk:
    def test_high_sugar_high_risk(self):
        assert _diabetic_risk(_n(sugar=35)).risk == RiskLevel.high

    def test_moderate_sugar_medium_risk(self):
        assert _diabetic_risk(_n(sugar=15)).risk == RiskLevel.medium

    def test_low_sugar_none_risk(self):
        assert _diabetic_risk(_n(sugar=2)).risk == RiskLevel.none


class TestHighlights:
    def test_high_protein_highlighted(self):
        h = _highlights(_n(protein=15))
        assert any('protein' in x.lower() for x in h)

    def test_high_fiber_highlighted(self):
        h = _highlights(_n(fiber=8))
        assert any('fiber' in x.lower() for x in h)

    def test_fallback_when_no_highlights(self):
        h = _highlights(_n(protein=2, fiber=1, sugar=6, saturated_fat=3, sodium=0.2))
        assert len(h) >= 1


class TestConcerns:
    def test_high_sugar_concern(self):
        c = _concerns(_n(sugar=25))
        assert any('sugar' in x.lower() for x in c)

    def test_no_concerns_for_good_product(self):
        c = _concerns(_n(sugar=1, saturated_fat=1, sodium=0.05, calories=150))
        assert c == []
