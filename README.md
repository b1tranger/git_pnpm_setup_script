# 🚀 Environment Setup Subproject (Git, Node.js, & pnpm)

Welcome to the **Environment Setup** project! This repository contains automated scripts, localized offline dependencies, and documentation to set up and uninstall **Git**, **Node.js (LTS)**, and **pnpm** on Windows environments without requiring manual downloads or continuous internet access.

---

## 📁 Directory Layout

```text
git_npnp_setup_script/
├── README.md                   # Overview, usage, and step-by-step guide (this file)
├── setup_environment.bat       # Double-clickable Windows Batch launcher for Setup
├── uninstall_environment.bat   # Double-clickable Windows Batch launcher for Uninstallation
├── .gitignore                  # Git ignore rules for system/editor files
├── .gitattributes             # Git attributes configuration
└── files/                      # Internal supporting scripts & localized installer dependencies
    ├── setup_installer.ps1     # Core setup engine (PowerShell)
    ├── uninstall_installer.ps1 # Core uninstallation engine (PowerShell)
    ├── download_deps.ps1       # Dependency manager script for localized binaries
    ├── pnpm_guide.md           # User guide & cheatsheet for PNPM
    ├── chat_archive.md         # Subproject development chat history
    └── deps/                   # Localized offline installers folder
        ├── Git-installer.exe   # Standalone Git 64-bit installer (~69.5 MB)
        ├── node-installer.msi  # Standalone Node.js LTS 64-bit installer (~30.9 MB)
        └── pnpm.exe            # Standalone pnpm binary (~98.1 MB)
```

---

## 🎯 Features

* **Zero-Dependency Localized Installation**: All installer binaries are stored in `files\deps\` so installation can run completely offline.
* **Smart Network Detection**: Detects if an active internet connection is available at runtime.
* **User Choice**: If online, asks if you want to download the latest package versions or proceed with localized files.
* **Automatic PATH Configuration**: Manages environment variables automatically during installation and uninstallation.
* **Complete Uninstallation Tool**: Includes a dedicated uninstallation workflow (`uninstall_environment.bat`) to cleanly remove installed tools and restore environment PATH settings.

---

## 📖 Step-by-Step Guide for Users

### Step 1: Run the Setup Script
From the repository root, run **`setup_environment.bat`**:

* **Option A (GUI / File Explorer)**: Double-click `setup_environment.bat`.
* **Option B (Terminal / Command Prompt)**:
  ```cmd
  setup_environment.bat
  ```

---

### Step 2: Respond to the Network Prompt
Upon launching:
1. The script tests network connectivity.
2. If **Online**, you will see:
   ```text
   Network detected! Would you like to check and download the latest installer packages from the internet? [Y/N] (Default: N)
   ```
   * Type **`Y`** (and hit Enter) to download fresh installers from the cloud into `files\deps\`.
   * Type **`N`** (or press Enter) to install immediately from local files in `files\deps\`.
3. If **Offline**, the script automatically installs using localized binaries from `files\deps\`.

---

### Step 3: Installation & Verification
The script will silently install missing components:
* Installs **Git** to `C:\Program Files\Git`
* Installs **Node.js LTS** to `C:\Program Files\nodejs`
* Configures **pnpm** in `%LOCALAPPDATA%\pnpm`

At the end of setup, you will see a status matrix verifying all installed versions:
```text
========================================================
               Installation Verification                 
========================================================
Git:  git version 2.48.1.windows.1
Node: v22.14.0
npm:  v10.9.2
pnpm: v11.22.0

Setup completed! Refer to 'files/pnpm_guide.md' for usage instructions.
```

---

### Step 4: Learn & Use PNPM
For full instructions on using `pnpm` in your projects (commands, `.pnpm` virtual store explanation, monorepos, and `npm` vs `pnpm` cheatsheet), open:
📄 **[files/pnpm_guide.md](file:///c:/Users/gsmur/OneDrive/Documents/GitHub/git_npnp_setup_script/files/pnpm_guide.md)**

---

## 🗑️ Uninstalling Installed Tools

If you ever need to uninstall Git, Node.js, and pnpm set up by this repository:

1. **Double-click `uninstall_environment.bat`** in the repository root (or run it from terminal).
2. Confirm the prompt (`Y/N`).
3. The script will:
   * Perform silent uninstallations for Git and Node.js.
   * Remove `%LOCALAPPDATA%\pnpm`.
   * Clean up all corresponding entries from your User `PATH` environment variable.

---

## 🔧 Updating Local Dependencies

If you want to update the offline binaries inside `files\deps\` at a later date, run:
```powershell
powershell -ExecutionPolicy Bypass -File .\files\download_deps.ps1
```
This will fetch the latest standalone installers for Git, Node.js LTS, and pnpm into `files\deps\`.
