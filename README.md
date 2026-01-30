# FloatBrowser

FloatBrowser is a minimalist, lightweight, and privacy-focused macOS menu bar client exclusively for **Google Gemini**.

Designed to be unobtrusive, it lives in your menu bar and can be detached into a floating window that stays on top of your work. No bloat, no subscriptions, just instant AI access.

<div align="center">
    <img src="requirements/menu-mode.png" alt="Menu Bar Mode" width="45%">
</div>

## Features

- **Menu Bar Access:** Quick access to Gemini with a single click or keystroke.
- **Float & Pin Mode:** Detach the window from the menu bar to keep it persistent on your desktop.
- **Always on Top:** Keep the chat window visible while you work in other apps (toggleable).
- **Native macOS Feel:** Minimized interface with native traffic light buttons and transparent headers.
- **Zoom Controls:** Adjustable text size for better readability (Right-click menu).
- **Global Shortcut:** Toggle the window instantly from anywhere using `⌥ + ⌘ + G`.
- **Battery Friendly:** Optimized for low energy impact (App Nap supported).
- **Privacy Focused:** Acts as a direct wrapper for Gemini. No data collection, no middleman servers.

## Screenshots

<div align="center">
  <img src="requirements/float-mode.png" alt="Float Mode" width="45%">
  
</div>

## Installation

1. Download the latest `FloatBrowser.dmg` from the [Releases](https://github.com/recepdemir/FloatBrowser/releases) page.
2. Open the DMG file and drag **FloatBrowser** to your **Applications** folder.
3. Launch the app. You will see the **Sparkles** (✨) icon in your menu bar.

> **Note:** Since this is an open-source app not signed with a paid Apple ID, you might see a warning that the app is "damaged" or from an "unidentified developer".
>
> **To fix this:**
> 1. Open **System Settings** -> **Privacy & Security**.
> 2. Scroll down to the Security section and click **"Open Anyway"**.
> 3. Or run this command in Terminal: `xattr -cr /Applications/FloatBrowser.app`

## Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| **⌥ + ⌘ + G** | Toggle Window (Global) |
| **⌘ + Q** | Quit App |
| **Right Click (Icon)** | Open Settings Menu |

## How to Use

1. **Click the Menu Bar Icon:** Opens the compact chat view.
2. **Pin the Window:** Click the 📌 icon to detach the window.
3. **Always on Top:** In pinned mode, click the layer icon (next to traffic lights) to keep the window above other apps.
4. **Settings:** Right-click the menu bar icon to adjust **Text Size** or enable **Launch at Login**.

## Tech Stack

- **Language:** Swift 5
- **UI:** SwiftUI + AppKit
- **Engine:** WKWebView (Optimized)

## License

This project is open source and available under the [MIT License](LICENSE).

---

<div align="center">
  <sub>Designed with simplicity in mind.</sub>
</div>
