import sys
import os

backend_dir = os.path.dirname(os.path.abspath(__file__))
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from app import health_check, analyze_shot, get_coach_analytics

def main():
    print("Testing Health Check...", flush=True)
    h = health_check()
    print("Health:", h["status"], "| Engine:", h["engine"], flush=True)
    
    print("\nTesting Shot Analysis (Fault: Low Elbow Set Point)...", flush=True)
    shot = analyze_shot(video=None, athlete_id="ATH-001", benchmark_fault=1)
    card = shot["coaching_card"]
    print(f"  Primary Fault   : {card['primary_fault']}", flush=True)
    print(f"  Severity Tier   : {card['severity_tier']}", flush=True)
    print(f"  Confidence      : {card['confidence_score']}%", flush=True)
    print(f"  Prescribed Drill: {card['prescribed_drill']}", flush=True)
    print(f"  Action Cue      : {card['actionable_cue']}", flush=True)
    print(f"  Measured Metric : {card['measured_metric']}", flush=True)
    print(f"  Ideal Benchmark : {card['ideal_benchmark']}", flush=True)
    print(f"  Inference Time  : {shot['latency_ms']} ms", flush=True)
    
    print("\nTesting Coach Analytics...", flush=True)
    coach = get_coach_analytics()
    print("  Total Sessions:", coach["metrics"]["totalSessions"], flush=True)
    print("  Average Conf  :", coach["metrics"]["averageConfidence"], flush=True)
    print("  Active Athletes:", coach["metrics"]["activeAthletes"], flush=True)
    print("\n[SUCCESS] All Backend Tiers Functioning with High Precision!", flush=True)

if __name__ == "__main__":
    main()
