# FinderHelper

FinderHelper is a lightweight macOS Menu Bar application that enhances your Finder workflow. It allows you to quickly open the currently selected folder (or active window) in **iTerm** or **Antigravity**.

## Features

- ⚡️ **Lightweight**: runs in the menu bar with minimal footprint.
- 📂 **Smart Detection**: Detects the currently selected folder in Finder, or falls back to the active window/Desktop.
- 📺 **iTerm Integration**: Open your current context directly in iTerm.
- 🚀 **Antigravity Integration**: Launch Antigravity with your current context.

## Installation

### From Source

1. Clone this repository:
   ```bash
   git clone https://github.com/vianney-laurent/FinderHelper.git
   cd FinderHelper
   ```

2. Build the application using the included script:
   ```bash
   chmod +x build.sh
   ./build.sh
   ```

3. The application will be created in the `build/` directory:
   ```bash
   open build/FinderHelper.app
   ```

## Usage

1. Launch `FinderHelper.app`. You will see a small icon (bolt/circle) in your macOS menu bar.
2. Navigate to any folder in Finder.
3. Click the menu bar icon and choose an action:
   - **Open in iTerm**
   - **Open in Antigravity**
   
*Note: On first run, macOS will prompt you to grant Finder automation permissions. This is required for the app to see your current directory.*

## Requirements

- macOS 12.0 or later
- [iTerm2](https://iterm2.com/) (for iTerm integration)
- Antigravity (for Antigravity integration)

## License

MIT
