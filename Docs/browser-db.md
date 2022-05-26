# Browser DB

## How to get your browser DB off the device

- Launch Neeva.
- Open Settings.
- Scroll down to "Neeva Browser $version", tap it once and choose "Toggle Debug Settings".
- Scroll down and hit "Copy Databases to App Container".
- Connect your device via USB.
- Open Xcode.
- Window > Devices. Choose your device.
- Find "Neeva" on the right side.
- Click the gear icon, and choose "Download Container…". Save it somewhere.
- After some time, Finder will open focused on an .xcappdata file.
- Right-click, "Show Package Contents".
- Navigate to `AppData/Documents`. Zip up `browser.*`.
