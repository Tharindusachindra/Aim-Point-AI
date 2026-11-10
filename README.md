# AimPointAI - Real-Time Basketball Kinematics & Corrective Coaching Engine

[![Architecture](https://img.shields.io/badge/Architecture-5--Tier%20Cloud--Edge-blue.svg)](#architecture)
[![Backend](https://img.shields.io/badge/Backend-FastAPI%20%7C%20Uvicorn-009688.svg)](backend/)
[![Desktop](https://img.shields.io/badge/Desktop-Electron%2033-47848F.svg)](electron/)
[![Python](https://img.shields.io/badge/Python-3.13%2B-3776AB.svg)](#environment-setup)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **Thesis Chapter 4 & 5 Operational Core**  
> Department of Computer Science, General Sir John Kotelawala Defence University (KDU 2026)  
> *Author: TS Kirindegamaarachchi*

---

## Overview

**AimPointAI** is an edge-optimized AI and biomechanics coaching application designed for real-time basketball shooting fault detection, kinematic trajectory evaluation, and prescriptive remediation.

The system combines monocular pose landmark streaming with a hybrid **Res-TCN + BiLSTM + Multi-Head Self-Attention** model to classify biomechanical shooting flaws (such as Low Elbow Set Point, Premature Knee Extension, Flared Elbow, and Insufficient Release Arc) and prescribe corrective drills.

---

## 5-Tier System Architecture

```
[Tier 1] Ingestion       : Monocular Video / Webcam (1080p @ 30fps)
[Tier 2] Feature Pipeline: Pelvic Centering + Savitzky-Golay Smoothing (60 frames)
[Tier 3] Classification  : Hybrid Res-TCN + BiLSTM + Multi-Head Self-Attention
[Tier 4] Remediation     : Sports Science Mechanics Ontology & Actionable Coaching Cards
[Tier 5] HCI Interface   : Commercial Multi-Tier Coach Analytics & Live HUD
```

---

## Environment Setup

### 1. Prerequisites
- **Python 3.10+** (tested with Python 3.13)
- **Node.js 18+** & **npm**

### 2. Python Virtual Environment
A clean virtual environment is configured in `.venv`:
```powershell
# Create virtual environment (if not already present)
python -m venv .venv

# Activate environment
.\.venv\Scripts\Activate.ps1

# Install required dependencies
pip install -r requirements.txt
```

### 3. Node & Electron Dependencies
```powershell
npm install
```

---

## Launching the Application

### Option A: Native Desktop App (Recommended)
Double-click **`AimPointAI-Desktop.bat`** or run:
```powershell
npm start
```
*Automatically boots the FastAPI server in the background and opens the native Electron desktop application.*

### Option B: Standalone Web App Mode (Edge / Chrome)
Double-click **`AimPointAI-Standalone.bat`**
*Launches the app in a dedicated, frameless window connected to `http://localhost:8080`.*

### Option C: Browser & API Server Only
```powershell
.\.venv\Scripts\python.exe start_server.py
```
* Access the Web App at: [http://localhost:8080](http://localhost:8080)
* Interactive Swagger Docs at: [http://localhost:8080/docs](http://localhost:8080/docs)
* Redoc API Docs at: [http://localhost:8080/redoc](http://localhost:8080/redoc)

### Option D: Packaged Standalone Binary
Launch the prebuilt standalone Windows binary:
```powershell
.\dist\AimPointAI-win32-x64\AimPointAI.exe
```

---

## Running Verification & Tests

To execute the unit and system verification test suites:

```powershell
# Run the 7-test system evaluation suite
.\.venv\Scripts\python.exe -m unittest discover -s backend/tests

# Run end-to-end API inference test
.\.venv\Scripts\python.exe backend/test_api.py
```

Expected output:
```
Ran 7 tests in 0.172s
OK
[BENCHMARK] End-to-end execution latency: ~33 ms (< 1500 ms target constraint)
[SUCCESS] All Backend Tiers Functioning with High Precision!
```

---

## Project Structure

```
Aim point AI/
├── backend/
│   ├── app.py                      # FastAPI REST API & static file mount
│   ├── requirements.txt            # Python dependencies
│   ├── test_api.py                 # Smoke test for API endpoints
│   ├── database/                   # SQLite database service & session models
│   ├── model/                      # Res-TCN + BiLSTM + Attention inference engine
│   ├── ontology/                   # Sports science pedagogical drill repository
│   ├── pose/                       # 3D angle & kinematic feature extraction
│   └── tests/                      # Unit & integration test suite
├── dist/                           # Packaged Windows desktop application
│   └── AimPointAI-win32-x64/       # Standalone executable & resources
├── electron/
│   ├── main.js                     # Main Electron process with auto-server lifecycle
│   ├── preload.js                  # Context bridge & IPC controls
│   └── splash.html                 # Startup splash screen
├── frontend/
│   └── index.html                  # Full single-page coaching analytics & HUD
├── .venv/                          # Local Python virtual environment
├── AimPointAI-Desktop.bat          # Desktop launch script
├── AimPointAI-Standalone.bat       # Standalone browser mode launch script
├── package.json                    # Electron & Node configuration
├── requirements.txt                # Root Python requirements
├── start_server.py                 # Unified server launcher
└── README.md                       # Documentation
```

