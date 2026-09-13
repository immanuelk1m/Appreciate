<p align="center">
  <img src="macos/AppIcon.png" width="128" height="128" alt="Appreciate icon">
</p>

# Appreciate ✨

🌐 [appreciate.srid.ca](https://appreciate.srid.ca)

A tiny reminder app. This personal macOS fork shows customizable reminders inside the menu bar; other platforms use the upstream screen overlays.

Comes with built-in **Reminder Packs** (Sensory, Actualism Method, Richard's Journal, Cooking, ...) and lets you create your own. Intervals are randomized. Other platforms also retain their upstream visual randomization.

Available for **macOS**, **Android**, **Windows**, and **Linux**.


## Personal macOS fork

This fork displays reminders **inside the menu bar only**, using the system font. A reminder temporarily replaces the sparkle icon, then restores it after Display Duration. Long text is truncated to a maximum 360-point item; hover to read the full text. Show Now uses the same behavior, repeated reminders restart the display duration, and disabling reminders restores the icon immediately. Other platforms retain upstream behavior.

Existing packs, intervals, display duration, and login settings are preserved. On this Mac the configured interval is 30–60 minutes and the duration is 5 seconds; new installations retain the upstream defaults.

Run `./update.command` to build and install the latest `master` from [immanuelk1m/Appreciate](https://github.com/immanuelk1m/Appreciate). It requires Xcode command-line tools, runs menu-bar regression checks, ad-hoc signs the app, and backs up the installed app and preferences before replacement. Installation failures restore the backup. Official upstream DMGs replace this customization. Upstream changes must be reviewed and merged into the fork explicitly.

The previous black/Noto Sans KR overlay source is retained for history but is no longer used by the macOS reminder path. The font's license is in `macos/Fonts/OFL.txt`.

## Features

- 🍎 **macOS menu bar** — reminder text appears briefly in the menu bar, then returns to the sparkle icon
- 🖥️ **Screen overlay (other platforms)** — reminder text appears directly on your desktop, then fades away
- 📦 **Reminder Packs** — built-in packs (Sensory, Actualism Method, Richard's Journal, Cooking) plus create your own
- ✏️ **Fully editable** — add, delete, and edit packs; each pack has multiple lines (random pick)
- 🎲 **Anti-habituation** — randomized timing; other platforms retain their upstream visual effects
- 🖥️🖥️ **Multi-monitor** — appears on all screens simultaneously (Windows)
- 🎯 **Background app** — menubar on macOS, foreground service on Android, system tray on Windows
- 🎧 **Voice mode** — automatically speaks reminders via TTS when headphones are connected (Android)

---

## macOS

### Install or update this fork

```bash
./update.command
```

This installs into `/Applications/Appreciate.app`. Upstream DMGs use screen overlays and do not contain this fork's menu-bar behavior.

### Build from source

```bash
cd macos
./build.sh
```

Requires Xcode Command Line Tools (`xcode-select --install`).

---

## Android

### Install from APK

1. Download the latest `.apk` from [Releases](../../releases)
2. Transfer to your phone and install (enable "Install from unknown sources" if prompted)
3. Open Appreciate → tap **"Grant Overlay Permission"** → enable the toggle
4. The app starts showing reminders immediately

### Build from source

```bash
nix develop                # enters dev shell with Android SDK, Java, Gradle
just deploy                # builds APK and installs to connected phone
```

Enable **USB debugging** on your phone first: Settings → About phone → tap Build number 7× → Developer options → USB debugging.

### First-time setup on phone

1. Open Appreciate
2. Tap **"⚠️ Grant Overlay Permission"** → toggle on for Appreciate
3. Back to app → **Enabled** switch is on by default
4. Done! Reminders will appear at random intervals

### Always On Display (AOD)

Appreciate registers as an Android Screensaver (Daydream). To show reminders on the Always On Display or when your device is idle:

1. Open Appreciate → tap **"🌙 Open Screen Saver Settings"**
2. Select **Appreciate** as your screen saver
3. Reminders will now appear on your lock screen / AOD when idle or charging

### Voice Mode (Headphones)

When Bluetooth headphones (or wired/USB headsets) are connected, Appreciate automatically **speaks reminders aloud** via Text-to-Speech — perfect for strolling, walking, or exercising without looking at your screen. The visual overlay still appears simultaneously.

- **Enabled by default** — toggle off with **"🎧 Voice when headphones connected"** in settings
- Works with Bluetooth A2DP, wired headphones, USB headsets, and BLE headsets
- **Anti-habituation** — speech rate, pitch, and voice are randomized on each utterance so you don't tune it out

---

## Windows

### Install from EXE

1. Download the latest `.exe` from [Releases](../../releases)
2. Run it — the ✨ icon appears in your system tray
3. No special permissions needed

### Build from source

Requires [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0).

```bash
cd windows
dotnet run
```

To publish a single-file executable:
```bash
cd windows
dotnet publish -c Release -r win-x64 --self-contained
```

---

## Linux

### Install via Nix

```bash
nix run github:srid/Appreciate
```

### Install from AppImage

AppImages are available for both **x86_64** and **ARM (aarch64)**.

1. Download the latest `.AppImage` for your architecture from [Releases](../../releases)
2. Make executable and run:
   ```bash
   chmod +x Appreciate-Linux-*.AppImage
   ./Appreciate-Linux-*.AppImage
   ```
   No dependencies needed — everything is bundled.

---

## Usage

| Setting | Description |
|---|---|
| **Reminder Pack** | Select a pack, add new ones (+), or delete existing (−) |
| **Reminder Text** | Editable lines for the current pack; a random one is picked each time |
| **Enabled** | Toggle reminders on/off |
| **Launch at Login/Boot** | Auto-start on system startup |
| **Min/Max Interval** | Random interval range (default 6s–1.5min) |
| **Display Duration** | How long the overlay stays visible |
| **✨ Show Now** | Trigger a reminder immediately |

## Releasing

1. Go to [Actions → Release](../../actions/workflows/release.yml)
2. Click **Run workflow**
3. Enter a version tag (e.g. `v1.1.0`)
4. The workflow builds macOS DMG, Android APK, Windows EXE, and Linux AppImages (x86_64 + ARM), and attaches all to the Release

## License

[GPL-3.0-or-later](LICENSE)
