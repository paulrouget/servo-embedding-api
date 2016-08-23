interface DevtoolsController {
  void openDevtools();
  void closeDevtools();
  boolean isDevToolsOpened();
  boolean isDevToolsFocused();
  void inspectElement(Number x, Number y);
  void inspectServiceWorker();
  void addWorkSpace(path);
  void removeWorkSpace(path);
  void hasServiceWorker(callback);
  void unregisterServiceWorker(callback);
  void enableDeviceEmulation(parameters);
  void disableDeviceEmulation();

  // Get the WebContents of DevTools for this WebContents.
  WebContents devToolsWebContents;

  // Get the debugger instance for this webContents.
  DebuggerInstance debugger;
}
