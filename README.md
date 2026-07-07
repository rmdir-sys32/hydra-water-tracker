# Hydrated

A lightweight, elegant, offline-first Flutter application for tracking daily water intake via NFC tags or manual logging.

## Features
- **NFC Tag Integration**: Tap a pre-configured NFC sticker on your cup or bottle to instantly log a drink.
- **Dedicated Settings Screen**: Access preferences in a clean, secondary view to manage daily goals and custom tap volumes.
- **Data Backup & Restore (JSON Export/Import)**: Export your entire hydration history JSON string to the clipboard with one click, or import a JSON backup to restore your logs offline.
- **Granular Log History**: Easily review your hydration logs for today and delete individual entries if logged by mistake.
- **Auto-Pruning**: Keeps database file size optimal by auto-pruning log entries older than 7 days on start.
- **Aesthetic Dark Theme**: Premium glassmorphism design with a glowing fluid radial progress tracker.

## Architecture & Storage
To avoid complex online database requirements and maintain absolute privacy, Hydrated operates completely offline:
- **SharedPreferences**: Stores lightweight user configurations, such as the active volume preset and daily hydration goal.
- **Local JSON File Storage**: Log entries are saved in standard JSON format in the device's application documents directory (`water_logs.json`). Reading and writing raw JSON text ensures extremely fast operations (under 5ms) without database overhead.
- **Automatic Migration**: On launch, the app automatically detects legacy data from previous versions (previously stored in SharedPreferences) and migrates them safely to the new JSON file structure.

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Physical mobile device with NFC support (for NFC scanning features)

### Installation
1. Clone the repository and navigate to the project directory:
   ```bash
   flutter pub get
   ```

2. Run the test suite to verify code soundness:
   ```bash
   flutter test
   ```

3. Launch the application on your connected device:
   ```bash
   flutter run
   ```

### NFC Setup
To automatically launch Hydrated when tapping your NFC tag:
- **Android**: Write an NDEF record to your NFC tag containing the URL: `https://mycounterapp.local` (configurable in `AndroidManifest.xml`).
