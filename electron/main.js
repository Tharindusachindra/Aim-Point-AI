const electron = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const http = require('http');
const fs = require('fs');

// Self-healing: If invoked via Node or with ELECTRON_RUN_AS_NODE=1 (e.g. from VS Code terminal),
// require('electron') resolves to an executable path string. Re-spawn cleanly under Electron runtime.
if (typeof electron === 'string') {
  const env = { ...process.env };
  delete env.ELECTRON_RUN_AS_NODE;
  const child = spawn(electron, [path.join(__dirname, '..')], {
    stdio: 'inherit',
    env,
    windowsHide: false
  });
  child.on('close', (code) => process.exit(code || 0));
  return;
}

const { app, BrowserWindow, session, ipcMain } = electron;

// Suppress Chromium GPU disk cache locks on Windows
app.commandLine.appendSwitch('disable-gpu-cache');

let mainWindow = null;
let splashWindow = null;
let pythonProcess = null;
const BACKEND_PORT = 8080;
const SERVER_URL = `http://127.0.0.1:${BACKEND_PORT}`;

// Enforce single instance lock to avoid port and cache conflicts
const gotTheLock = app.requestSingleInstanceLock();
if (!gotTheLock) {
  app.quit();
} else {
  app.on('second-instance', () => {
    if (mainWindow) {
      if (mainWindow.isMinimized()) mainWindow.restore();
      mainWindow.focus();
    }
  });
}

// 1. Locate Local Python Executable
function getPythonPath() {
  const rootDir = path.join(__dirname, '..');
  const possiblePaths = [
    path.join(rootDir, '.venv', 'Scripts', 'python.exe'),
    path.join(rootDir, 'venv', 'Scripts', 'python.exe'),
    path.join(rootDir, '..', '..', '..', '.venv', 'Scripts', 'python.exe'),
    path.join(rootDir, '..', '..', '..', '..', '.venv', 'Scripts', 'python.exe'),
    'C:\\Users\\CHAMA COMPUTERS\\Desktop\\Aim point AI\\.venv\\Scripts\\python.exe',
    process.env.PYTHON_PATH
  ];

  for (const p of possiblePaths) {
    if (p && fs.existsSync(p)) {
      return p;
    }
  }
  return 'python';
}

function getServerScriptPath() {
  const rootDir = path.join(__dirname, '..');
  const possibleScripts = [
    path.join(rootDir, 'start_server.py'),
    path.join(__dirname, '..', 'start_server.py'),
    path.join(rootDir, '..', '..', '..', 'start_server.py'),
    'C:\\Users\\CHAMA COMPUTERS\\Desktop\\Aim point AI\\start_server.py'
  ];

  for (const s of possibleScripts) {
    if (s && fs.existsSync(s)) {
      return s;
    }
  }
  return path.join(rootDir, 'start_server.py');
}

// 2. Start Local FastAPI Backend
function startPythonBackend() {
  const pythonPath = getPythonPath();
  const scriptPath = getServerScriptPath();
  const workingDir = path.dirname(scriptPath);

  console.log(`[AimPointAI Desktop] Starting Python Backend with: ${pythonPath}`);

  pythonProcess = spawn(pythonPath, [scriptPath], {
    cwd: workingDir,
    env: { ...process.env, PORT: String(BACKEND_PORT), PYTHONUNBUFFERED: '1' },
    stdio: 'pipe'
  });

  pythonProcess.stdout.on('data', (data) => {
    console.log(`[Python] ${data.toString().trim()}`);
  });

  pythonProcess.stderr.on('data', (data) => {
    console.error(`[Python ERR] ${data.toString().trim()}`);
  });

  pythonProcess.on('close', (code) => {
    console.log(`[AimPointAI Desktop] Python process exited with code ${code}`);
  });
}

// 3. Poll Server Until Live
function waitForServer(callback, maxAttempts = 60) {
  let attempts = 0;
  let resolved = false;
  const interval = setInterval(() => {
    attempts++;
    const req = http.get(`${SERVER_URL}/api/health`, (res) => {
      if (!resolved && (res.statusCode === 200 || res.statusCode === 404)) {
        resolved = true;
        clearInterval(interval);
        callback(true);
      }
    });

    req.on('error', () => {
      if (!resolved && attempts >= maxAttempts) {
        resolved = true;
        clearInterval(interval);
        callback(false);
      }
    });

    req.setTimeout(1000, () => {
      req.destroy();
    });

    req.end();
  }, 500);
}

// 4. Create Sleek Splash Screen
function createSplashWindow() {
  splashWindow = new BrowserWindow({
    width: 520,
    height: 360,
    frame: false,
    transparent: true,
    alwaysOnTop: true,
    resizable: false,
    show: true,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true
    }
  });

  splashWindow.loadFile(path.join(__dirname, 'splash.html'));
}

// 5. Create Main Native Desktop Window
function createMainWindow() {
  mainWindow = new BrowserWindow({
    width: 1440,
    height: 920,
    minWidth: 1080,
    minHeight: 720,
    show: false,
    backgroundColor: '#070A12',
    title: 'AimPointAI - Basketball Biomechanics & Shooting Form Correction',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true
    }
  });

  // Auto-grant Camera / Webcam permissions for seamless monocular capture
  session.defaultSession.setPermissionRequestHandler((webContents, permission, callback) => {
    if (permission === 'media' || permission === 'camera' || permission === 'microphone') {
      callback(true);
    } else {
      callback(true);
    }
  });

  mainWindow.loadURL(SERVER_URL);

  let showTriggered = false;
  const revealMainWindow = () => {
    if (showTriggered) return;
    showTriggered = true;
    if (splashWindow && !splashWindow.isDestroyed()) {
      splashWindow.close();
      splashWindow = null;
    }
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.show();
      mainWindow.focus();
    }
  };

  mainWindow.once('ready-to-show', revealMainWindow);

  // Auto-retry if initial page load encounters temporary connection refusal while backend boots
  mainWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription) => {
    console.log(`[AimPointAI Desktop] Load note (${errorCode}: ${errorDescription}), retrying connection...`);
    setTimeout(() => {
      if (mainWindow && !mainWindow.isDestroyed()) {
        mainWindow.loadURL(SERVER_URL).catch(() => {});
      }
    }, 1500);
  });

  // Safety fallback: Never leave the user stuck with an invisible window or lingering splash screen
  setTimeout(revealMainWindow, 6000);

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

// IPC Window Controls
ipcMain.on('window-minimize', () => { if (mainWindow) mainWindow.minimize(); });
ipcMain.on('window-maximize', () => {
  if (mainWindow) {
    mainWindow.isMaximized() ? mainWindow.unmaximize() : mainWindow.maximize();
  }
});
ipcMain.on('window-close', () => { if (mainWindow) mainWindow.close(); });

// Application Lifecycle
app.whenReady().then(() => {
  createSplashWindow();

  // Check if server is already running before spawning a new python process
  const checkReq = http.get(`${SERVER_URL}/api/health`, (res) => {
    if (res.statusCode === 200) {
      console.log('[AimPointAI Desktop] Existing Python backend detected on port 8080.');
      createMainWindow();
    } else {
      startPythonBackend();
      waitForServer((isReady) => {
        if (isReady) {
          console.log('[AimPointAI Desktop] Server live! Launching main window...');
        } else {
          console.error('[AimPointAI Desktop] Failed to connect to local server in time.');
        }
        createMainWindow();
      });
    }
  });

  checkReq.on('error', () => {
    startPythonBackend();
    waitForServer((isReady) => {
      if (isReady) {
        console.log('[AimPointAI Desktop] Server live! Launching main window...');
      } else {
        console.error('[AimPointAI Desktop] Failed to connect to local server in time.');
      }
      createMainWindow();
    });
  });

  checkReq.setTimeout(1000, () => {
    checkReq.destroy();
  });
  checkReq.end();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createMainWindow();
  });
});

// Clean up Python Backend Child Process
function cleanupPython() {
  if (pythonProcess) {
    console.log('[AimPointAI Desktop] Stopping Python backend process...');
    try {
      if (process.platform === 'win32') {
        spawn('taskkill', ['/pid', pythonProcess.pid, '/f', '/t']);
      } else {
        pythonProcess.kill('SIGTERM');
      }
    } catch (e) {
      console.error('Error killing python process:', e);
    }
    pythonProcess = null;
  }
}

app.on('before-quit', cleanupPython);
app.on('window-all-closed', () => {
  cleanupPython();
  if (process.platform !== 'darwin') app.quit();
});

