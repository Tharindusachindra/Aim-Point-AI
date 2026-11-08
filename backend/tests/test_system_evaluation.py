"""
AimPointAI - Chapter 6 System Testing & Verification Suite
Operationalizes Unit Tests (Table 6.1) and System Integration Tests (Table 6.2)
"""

import sys
import os
import time
import unittest
import numpy as np

# Ensure backend root on path
backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from pose.kinematic_calculator import (
    KinematicFeatureExtractor, 
    calculate_angle_3d, 
    savitzky_golay_filter,
    FAULT_CLASSES
)
from model.architecture import classifier_engine
from ontology.pedagogical_engine import pedagogical_engine
from database.database_service import db_service
from app import analyze_shot, health_check, get_coach_analytics

class AimPointSystemTestSuite(unittest.TestCase):

    def setUp(self):
        self.extractor = KinematicFeatureExtractor(target_frames=60)

    def test_unit_tier2_3d_angle_calculation(self):
        """Test Table 6.1: Mathematical precision of 3D interior joint angles"""
        # Right angle triangle in 3D: (0, 1, 0) -> (0, 0, 0) -> (1, 0, 0)
        a = np.array([0.0, 1.0, 0.0])
        b = np.array([0.0, 0.0, 0.0]) # vertex
        c = np.array([1.0, 0.0, 0.0])
        angle = calculate_angle_3d(a, b, c)
        self.assertAlmostEqual(angle, 90.0, places=2)

        # Straight line: 180 degrees
        c_straight = np.array([0.0, -1.0, 0.0])
        angle_straight = calculate_angle_3d(a, b, c_straight)
        self.assertAlmostEqual(angle_straight, 180.0, places=2)

    def test_unit_tier2_savitzky_golay_smoothing(self):
        """Test Table 6.1: Suppression of high-frequency tracking jitter"""
        clean_signal = np.sin(np.linspace(0, np.pi, 60))
        noise = np.random.normal(0, 0.08, 60)
        noisy_signal = clean_signal + noise
        
        smoothed = savitzky_golay_filter(noisy_signal, window_size=7, order=2)
        # Jitter variance of smoothed signal should be significantly lower than noisy signal
        raw_diff_var = np.var(np.diff(noisy_signal))
        smooth_diff_var = np.var(np.diff(smoothed))
        self.assertLess(smooth_diff_var, raw_diff_var)

    def test_unit_tier2_spatial_normalization(self):
        """Test Table 6.1: Pelvic centering & scale invariance"""
        raw_landmarks = self.extractor.generate_synthetic_shot_landmarks(fault_type=0)
        norm_landmarks = self.extractor.normalize_spatial_coordinates(raw_landmarks)
        
        self.assertEqual(norm_landmarks.shape, (60, 33, 3))
        # Verify hip center is at (0, 0, 0)
        mid_hip = (norm_landmarks[0, 23] + norm_landmarks[0, 24]) / 2.0
        self.assertAlmostEqual(float(np.linalg.norm(mid_hip)), 0.0, places=4)

    def test_unit_tier3_neural_inference_tensor_contract(self):
        """Test Table 6.1: Feature tensor shape (60 x 12) & Softmax probability contract"""
        raw_landmarks = self.extractor.generate_synthetic_shot_landmarks(fault_type=1)
        kinematics = self.extractor.extract_kinematic_channels(raw_landmarks)
        tensor = self.extractor.construct_feature_tensor(raw_landmarks)
        
        self.assertEqual(tensor.shape, (60, 12))
        
        pred_class, conf, probs = classifier_engine.predict(tensor, kinematics)
        self.assertIn(pred_class, [0, 1, 2, 3, 4])
        self.assertGreaterEqual(conf, 0.85) # High confidence guarantee
        self.assertAlmostEqual(float(np.sum(probs)), 1.0, places=4)

    def test_unit_tier4_pedagogical_ontology_mapping(self):
        """Test Table 6.1: Rule evaluation, severity grading & single drill prescription"""
        # Low Elbow test: elbow angle = 36 deg (< 43.34 threshold)
        mock_kin = {
            "elbow_angles": [36.0, 40.0, 50.0],
            "trunk_tilt": [22.0],
            "release_angles": [48.0]
        }
        card = pedagogical_engine.evaluate(model_class=1, confidence=0.94, kinematics=mock_kin)
        self.assertEqual(card.fault_name, "Low Elbow Set Point")
        self.assertEqual(card.prescribed_drill, "One-Handed Wall Touches")
        self.assertEqual(card.severity_level, 3) # Severe (> 20 deg deviation from 88.5)
        self.assertIn("flattens your launch angle", card.why_it_matters)

    def test_unit_tier5_sqlite_persistence(self):
        """Test Table 6.1: Transactional session insertion and retrieval"""
        analytics_before = db_service.get_coach_analytics()
        prev_count = analytics_before["metrics"]["totalSessions"]
        
        res = analyze_shot(video=None, athlete_id="ATH-001", benchmark_fault=0)
        self.assertEqual(res["status"], "success")
        
        analytics_after = db_service.get_coach_analytics()
        self.assertEqual(analytics_after["metrics"]["totalSessions"], prev_count + 1)

    def test_system_end_to_end_latency_nfr01(self):
        """Test Table 6.2: End-to-end latency constraint (strictly < 1500 ms)"""
        start = time.perf_counter()
        res = analyze_shot(video=None, athlete_id="ATH-002", benchmark_fault=2)
        elapsed_ms = (time.perf_counter() - start) * 1000.0
        
        self.assertEqual(res["status"], "success")
        self.assertLess(elapsed_ms, 1500.0)
        print(f"\n[BENCHMARK] End-to-end execution latency: {elapsed_ms:.2f} ms (< 1500 ms target)")

if __name__ == "__main__":
    unittest.main()

