"""
AimPointAI - Relational Data Models & Schemas
Implements Table Entities defined in Thesis Appendix B (cli) & Section 4.5.6
"""

from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field
from datetime import datetime

class AthleteModel(BaseModel):
    athlete_id: str
    name: str
    position: str = "Guard"
    team: str = "KDU Varsity Basketball"
    sessions_count: int = 0
    primary_fault: str = "Ideal Form"
    consistency_score: float = 88.5
    last_active: str = Field(default_factory=lambda: datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

class TrainingSessionModel(BaseModel):
    session_id: str
    timestamp: str = Field(default_factory=lambda: datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    duration_ms: int = 2000
    release_angle_deg: float
    hardware_fps: int = 30
    inference_latency_ms: int
    athlete_id: Optional[str] = "ATH-001"
    video_name: Optional[str] = "shot_capture.mp4"

class CoachingCardModel(BaseModel):
    card_id: str
    session_id: str
    fault_classification: str
    severity_tier: str # 'Minor Deviation', 'Moderate Fault', 'Severe Breakdown'
    prescribed_drill: str
    confidence_score: float
    why_it_matters: str
    actionable_cue: str
    measured_metric: str
    ideal_benchmark: str

class BiomechanicalReport(BaseModel):
    athlete: AthleteModel
    session: TrainingSessionModel
    card: CoachingCardModel
    accuracy_level: float = 99.8

