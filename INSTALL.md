# Installation Guide - Canary Map Editor

## Quick Install (Linux)

### Method 1: User Installation (Recommended)

Install for the current user only (no root required):

```bash
# Build the project
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$HOME/.local ..
cmake --build . -j$(nproc)

# Install desktop integration
cmake --install .
```

**What gets installed:**
- Desktop file: `~/.local/share/applications/canary-map-editor.desktop`
- Icons: `~/.local/share/icons/hicolor/{16,32,48,64,128,256}x*/apps/canary-map-editor.png`
- Executable: `~/.local/bin/canary-map-editor` (if binary installation configured)

**Post-install:**
- The application will appear in your application menu
- Icon will be displayed correctly in all desktop environments
- Icon cache and desktop database are updated automatically

---

### Method 2: System-Wide Installation (Requires root)

Install for all users on the system:

```bash
# Build the project
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr/local ..
cmake --build . -j$(nproc)

# Install desktop integration (requires sudo)
sudo cmake --install .
```

**What gets installed:**
- Desktop file: `/usr/local/share/applications/canary-map-editor.desktop`
- Icons: `/usr/local/share/icons/hicolor/{16,32,48,64,128,256}x*/apps/canary-map-editor.png`
- Executable: `/usr/local/bin/canary-map-editor` (if binary installation configured)

---

### Method 3: Just Run the Binary (No Installation)

If you just want to run the application without installing:

```bash
# Build the project
mkdir -p build && cd build
cmake ..
cmake --build . -j$(nproc)

# Run directly
./canary-map-editor
```

**Note:** The application will work, but:
- Won't appear in application menu
- Icon will only show in window titlebar (embedded icon)

---

## Icon Installation Details

The installation process automatically:

1. **Installs multi-size icons** (16x16 to 256x256 pixels)
   - Ensures proper display on all screen resolutions
   - Supports HiDPI/Retina displays
   - Follows freedesktop.org icon theme specification

2. **Creates desktop entry** (`.desktop` file)
   - Adds application to system menu
   - Associates icons with the application
   - Defines proper application categories

3. **Updates system caches**
   - Runs `gtk-update-icon-cache` to refresh icon cache
   - Runs `update-desktop-database` to refresh application menu

---

## Verification

To verify the installation worked:

```bash
# Check if desktop file exists
ls -l ~/.local/share/applications/canary-map-editor.desktop
# or for system install:
ls -l /usr/local/share/applications/canary-map-editor.desktop

# Check if icons are installed
ls -l ~/.local/share/icons/hicolor/256x256/apps/canary-map-editor.png
# or for system install:
ls -l /usr/local/share/icons/hicolor/256x256/apps/canary-map-editor.png

# Check if application appears in menu
# Open your application menu and search for "Canary Map Editor"
```

---

## Uninstallation

### User Installation

```bash
cd build
cmake --install . --component Uninstall
# or manually:
rm -f ~/.local/share/applications/canary-map-editor.desktop
rm -f ~/.local/share/icons/hicolor/*/apps/canary-map-editor.png
gtk-update-icon-cache ~/.local/share/icons/hicolor/
update-desktop-database ~/.local/share/applications/
```

### System Installation

```bash
cd build
sudo cmake --install . --component Uninstall
# or manually:
sudo rm -f /usr/local/share/applications/canary-map-editor.desktop
sudo rm -f /usr/local/share/icons/hicolor/*/apps/canary-map-editor.png
sudo gtk-update-icon-cache /usr/local/share/icons/hicolor/
sudo update-desktop-database /usr/local/share/applications/
```

---

## Build Requirements

- CMake 3.22+
- C++20 compiler (GCC 11+ or Clang 13+)
- wxWidgets 3.0+ (GTK3)
- OpenGL libraries
- ImageMagick (for icon generation)

### Install dependencies (Ubuntu/Debian):

```bash
sudo apt update
sudo apt install build-essential cmake git \
    libwxgtk3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev \
    libarchive-dev zlib1g-dev imagemagick
```

---

## Troubleshooting

### Icons not showing in application menu

Try manually updating the caches:

```bash
# For user installation
gtk-update-icon-cache -f ~/.local/share/icons/hicolor/
update-desktop-database ~/.local/share/applications/

# For system installation
sudo gtk-update-icon-cache -f /usr/local/share/icons/hicolor/
sudo update-desktop-database /usr/local/share/applications/
```

Then log out and log back in, or restart your desktop environment.

### Application not appearing in menu

Check if the desktop file is valid:

```bash
desktop-file-validate ~/.local/share/applications/canary-map-editor.desktop
```

### Permission issues during system installation

Make sure you're using `sudo` for system-wide installation:

```bash
sudo cmake --install .
```

---

For more information, see [README.md](README.md)
