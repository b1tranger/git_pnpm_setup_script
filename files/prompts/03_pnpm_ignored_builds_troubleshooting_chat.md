# 💬 User-AI Chat Archive (Session 3): PNPM Ignored Builds Troubleshooting & Guide Update

> **Conversation ID**: 439503cc-dcfd-4e58-9e0c-e9f104441b9d  
> **Date**: August 20, 2026  
> **Subproject Folder**: [files/](file:///c:/Users/gsmur/OneDrive/Documents/GitHub/git_npnp_setup_script/files)  

---

## 👤 User (Turn 1)

using `pnpm dev` shows:
```text
Downloading @excalidraw/excalidraw@0.17.6: 10.63 MB/10.63 MB, done
[WARN] 11 deprecated subdependencies found: abstract-leveldown@6.2.3, abstract-leveldown@6.3.0, deferred-leveldown@5.3.0, encoding-down@6.3.0, level-codec@9.0.2, level-concat-iterator@2.0.1, level-errors@2.0.1, level-js@5.0.2, level-packager@5.1.1, leveldown@5.6.0, levelup@4.4.0
Packages: +193
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Packages are hard linked from the content-addressable store to the virtual store.
  Content-addressable store is at: C:\Users\gsmur\AppData\Local\pnpm\store\v11
  Virtual store is at:             node_modules/.pnpm
Progress: resolved 240, reused 0, downloaded 193, added 193, done

dependencies:
+ @azure/msal-browser 3.30.0 (5.19.0 is available)
+ @excalidraw/excalidraw 0.17.6 (0.18.1 is available)
+ clsx 2.1.1
+ idb 8.0.3
+ jszip 3.10.1
+ lucide-react 0.344.0 (1.33.0 is available)
+ react 18.3.1 (19.2.8 is available)
+ react-dom 18.3.1 (19.2.8 is available)
+ tailwind-merge 2.6.1 (3.6.0 is available)
+ y-websocket 1.5.4 (3.1.0 is available)
+ yjs 13.6.32

devDependencies:
+ @types/node 20.19.43 (26.2.0 is available)
+ @types/react 18.3.31 (19.2.18 is available)
+ @types/react-dom 18.3.7 (19.2.4 is available)
+ @types/ws 8.18.1
+ @vitejs/plugin-react 4.7.0
+ autoprefixer 10.5.4
+ postcss 8.5.26
+ tailwindcss 3.4.19 (4.3.3 is available)
+ typescript 5.9.3 (7.0.2 is available)
+ vite 5.4.21
+ ws 8.21.3

[ERR_PNPM_IGNORED_BUILDS] Ignored build scripts: esbuild@0.21.5, leveldown@5.6.0

Run "pnpm approve-builds" to pick which dependencies should be allowed to run scripts.
[ERROR] Command failed with exit code 1: "C:\Users\gsmur\AppData\Local\pnpm\pnpm.exe" install

pnpm: Command failed with exit code 1: "C:\Users\gsmur\AppData\Local\pnpm\pnpm.exe" install
    at getFinalError (file:///C:/Users/gsmur/AppData/Local/pnpm/dist/pnpm.mjs:89203:14)
    at makeError (file:///C:/Users/gsmur/AppData/Local/pnpm/dist/pnpm.mjs:91510:21)
    at getSyncResult (file:///C:/Users/gsmur/AppData/Local/pnpm/dist/pnpm.mjs:93354:10)
    at spawnSubprocessSync (file:///C:/Users/gsmur/AppData/Local/pnpm/dist/pnpm.mjs:93314:14)
    at execaCoreSync (file:///C:/Users/gsmur/AppData/Local/pnpm/dist/pnpm.mjs:93244:23)
    at callBoundExeca (file:///C:/Users/gsmur/AppData/Local/pnpm/dist/pnpm.mjs:95772:23)
    at boundExeca (file:///C:/Users/gsmur/AppData/Local/pnpm/dist/pnpm.mjs:95749:49)
    at sync2 (file:///C:/Users/gsmur/AppData/Local/pnpm/dist/pnpm.mjs:95908:10)
    at runPnpmCli (file:///C:/Users/gsmur/AppData/Local/pnpm/dist/pnpm.mjs:271521:5)
    at runDepsStatusCheck (file:///C:/Users/gsmur/AppData/Local/pnpm/dist/pnpm.mjs:273323:7)
```

---

## 🤖 AI Assistant (Turn 1)

### Why This Happens

In **pnpm v10+**, dependencies with build/install scripts (such as `esbuild` and `leveldown`) are **blocked by default** for security reasons. Because packages like `esbuild` require postinstall scripts to set up their native binaries, pnpm halts the process until you explicitly authorize them.

---

### How to Fix It

#### Option 1: Run the interactive approval tool (Recommended)

Run the command suggested by pnpm in your project root:

```bash
pnpm approve-builds
```

1. Use the **Arrow keys** to navigate and **Spacebar** to select `esbuild` and `leveldown`.
2. Press **Enter** to confirm.

This will automatically configure `pnpm.onlyBuiltDependencies` in your `package.json` and execute the build scripts.

---

#### Option 2: Add `onlyBuiltDependencies` directly to `package.json`

Open your project's `package.json` and add the `pnpm` configuration block:

```json
{
  "name": "your-project",
  "version": "1.0.0",
  "dependencies": { ... },
  "devDependencies": { ... },
  "pnpm": {
    "onlyBuiltDependencies": [
      "esbuild",
      "leveldown"
    ]
  }
}
```

Then run:

```bash
pnpm install
pnpm dev
```

---

#### Option 3: Allow all build scripts in `.npmrc`

If you want pnpm to behave like older versions (allowing build scripts without restrictions), create or edit `.npmrc` in your project root:

```ini
ignored-builds=
```

---

## 👤 User (Turn 2)

so I do not neet to update the script @[c:\Users\gsmur\OneDrive\Documents\GitHub\git_npnp_setup_script\setup_environment.bat] to fix thoes issues?

---

## 🤖 AI Assistant (Turn 2)

**No, you do not need to update `setup_environment.bat` (or `setup_installer.ps1`).**

### Why:
* **The setup script worked properly**: It successfully installed Git, Node.js, and pnpm on your machine.
* **The issue is project-specific, not an environment issue**: In newer versions of pnpm (v10+), pnpm introduced a security feature that blocks dependency install/build scripts by default on each project repository.
* **The fix belongs in your project**: You only need to run:
  ```bash
  pnpm approve-builds
  ```
  in the root folder of the project you are running `pnpm dev` in. 

Once approved, pnpm remembers your choice in that project's `package.json` and won't prompt you again for those packages.

---

## 👤 User (Turn 3)

update @[c:\Users\gsmur\OneDrive\Documents\GitHub\git_npnp_setup_script\files\pnpm_guide.md] and archive this chat as it is in @[c:\Users\gsmur\OneDrive\Documents\GitHub\git_npnp_setup_script\files\prompts]

---

## 🤖 AI Assistant (Turn 3)

1. Updated **[files/pnpm_guide.md](file:///c:/Users/gsmur/OneDrive/Documents/GitHub/git_npnp_setup_script/files/pnpm_guide.md)** with a new troubleshooting section: **"Troubleshooting & Build Script Approvals (pnpm v10+)"**.
2. Documented `[ERR_PNPM_IGNORED_BUILDS]`, explaining the security background and the three available fixes (`pnpm approve-builds`, `pnpm.onlyBuiltDependencies` in `package.json`, and `.npmrc`).
3. Archived the complete conversation session as **[03_pnpm_ignored_builds_troubleshooting_chat.md](file:///c:/Users/gsmur/OneDrive/Documents/GitHub/git_npnp_setup_script/files/prompts/03_pnpm_ignored_builds_troubleshooting_chat.md)**.
