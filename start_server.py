"""
AimPointAI - Unified Production Server Launcher
Starts the FastAPI Asynchronous Backend & Serves Commercial Modern Frontend
"""

import os
import sys
import socket
import uvicorn

# Ensure backend is on sys.path
root_dir = os.path.dirname(os.path.abspath(__file__))
backend_dir = os.path.join(root_dir, "backend")
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

def is_port_available(port: int) -> bool:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        try:
            s.bind(('0.0.0.0', port))
            return True
        except OSError:
            return False

def get_free_port(preferred_ports=[8000, 8080, 8008, 5000]) -> int:
    for p in preferred_ports:
        if is_port_available(p):
            return p
    return 8080

def print_banner(port=8080):
    banner = rf"""
========================================================================
   ___ _            ____       _       _      _    ___ 
  / _ (_)_ __ ___  |  _ \ ___ (_)_ __ | |_   / \  |_ _|
 / /_\ | | '_ ` _ \ | |_) / _ \| | '_ \| __| / _ \  | | 
/ /_\\ | | | | | | ||  __/ (_) | | | | | |_ / ___ \ | | 
\____/_|_|_| |_| |_||_|   \___/|_|_| |_|\__/_/   \_\___|

 Real-Time Detection of Basketball Shooting Mistakes & Corrective Coaching
 Grounded in Monocular Pose Estimation, Res-TCN + BiLSTM + Attention
========================================================================
 [Tier 1] Ingestion: Standard Monocular Capture (1080p @ 30fps)
 [Tier 2] Feature Extraction: Pelvic Centering + Savitzky-Golay Smoothing
 [Tier 3] Classification: Hybrid Res-TCN + BiLSTM + Multi-Head Self-Attention
 [Tier 4] Remediation: Sports Science Mechanics Ontology & Actionable Cards
 [Tier 5] HCI Interface: Commercial Multi-Tier Coach Analytics & Live HUD
------------------------------------------------------------------------
 Web Application Live at: http://localhost:{port}
 API Documentation at   : http://localhost:{port}/docs
========================================================================
"""
    print(banner)

def run():
    env_port = os.environ.get("PORT")
    target_port = int(env_port) if env_port else get_free_port()
    print_banner(target_port)
    uvicorn.run("app:app", host="0.0.0.0", port=target_port, reload=False, app_dir=backend_dir)

if __name__ == "__main__":
    run()

