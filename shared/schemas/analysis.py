from __future__ import annotations
from enum import Enum
from pydantic import BaseModel


class HealthVerdict(str, Enum):
    excellent = "excellent"
    good = "good"
    moderate = "moderate"
    poor = "poor"
    avoid = "avoid"


class RiskLevel(str, Enum):
    none = "none"
    low = "low"
    medium = "medium"
    high = "high"


class DiabeticFlag(BaseModel):
    risk: RiskLevel
    explanation: str


class AllergenWarning(BaseModel):
    allergen: str
    note: str


class Alternative(BaseModel):
    name: str
    reason: str


class AnalysisResult(BaseModel):
    barcode: str
    verdict: HealthVerdict
    health_score: int
    summary: str
    highlights: list[str]
    concerns: list[str]
    diabetic_flag: DiabeticFlag
    allergen_warnings: list[AllergenWarning]
    alternatives: list[Alternative]
