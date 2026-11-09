const { contextBridge, ipcRenderer } = require('electron');

// Expose safe desktop IPC APIs to the frontend
contextBridge.exposeInMainWorld('desktopAPI', {
  isDesktop: true,
  appVersion: '1.0.0',
  platform: process.platform,
  minimize: () => ipcRenderer.send('window-minimize'),
  maximize: () => ipcRenderer.send('window-maximize'),
  close: () => ipcRenderer.send('window-close')
});

