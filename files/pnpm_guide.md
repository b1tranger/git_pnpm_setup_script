# PNPM Guide & Best Practices for Node.js Projects

Welcome to the **PNPM Guide** for projects in this repository. This document explains why `pnpm` is preferred over standard `npm`, how `pnpm` manages `node_modules`, and how to use `pnpm` effectively.

---

## 📖 Table of Contents
1. [Why PNPM over NPM?](#-why-pnpm-over-npm)
2. [How PNPM Manages `node_modules`](#-how-pnpm-manages-node_modules)
3. [Quick Installation](#-quick-installation)
4. [Command Cheatsheet (NPM vs PNPM)](#-command-cheatsheet-npm-vs-pnpm)
5. [Working with Projects](#-working-with-projects)
6. [Monorepo & Workspaces](#-monorepo--workspaces)
7. [Best Practices](#-best-practices)

---

## 🚀 Why PNPM over NPM?

`pnpm` (Performant NPM) is a modern package manager designed to be faster, more disk-efficient, and stricter than traditional `npm` or `yarn`.

### Key Advantages:
* **Massive Disk Space Savings**: `npm` duplicates dependency files across every project on your machine. `pnpm` uses a single **Global Content-Addressable Store** (`~/.local/share/pnpm/store/v3`). All project `node_modules` hard-link back to this central store.
* **Strict Dependency Tree (No Phantom Dependencies)**: `npm` flattens `node_modules`, allowing code to reference sub-dependencies not explicitly declared in `package.json`. `pnpm` uses symlinks to create a strict hierarchy where projects can *only* access explicitly declared dependencies.
* **Blazing Fast Installations**: `pnpm` executes resolution, fetching, and linking phases in parallel with strict caching, avoiding redundant network requests.

---

## 📂 How PNPM Manages `node_modules`

Instead of creating a giant flat directory of nested folders, `pnpm` creates a hidden `.pnpm` folder inside `node_modules` called the **Virtual Store**.

### Directory Structure Example:
```text
node_modules
├── .pnpm
│   ├── express@4.18.2/node_modules/express
│   │   ├── package.json
│   │   └── ... (hard-linked to global pnpm store)
│   └── body-parser@1.20.1/node_modules/body-parser
│       └── ...
├── express -> .pnpm/express@4.18.2/node_modules/express (symlink)
└── package.json
```

1. **Global Store**: Actual files are saved once on disk in the global `pnpm` store.
2. **Hard Links**: The `.pnpm` directory contains hard links to the global store (zero duplicate disk cost).
3. **Symlinks**: Top-level `node_modules` contains symlinks pointing directly into `.pnpm/<pkg-name>@<version>/node_modules/<pkg-name>`.

---

## 🛠️ Quick Installation

You can install `pnpm` using any of the following methods:

### Method 1: Using the Repository Setup Script (Recommended Offline/Online)
Run `setup_environment.bat` located in the root directory:
```cmd
setup_environment.bat
```

### Method 2: Windows Package Manager (winget)
```cmd
winget install --id pnpm.pnpm -e
```

### Method 3: Corepack (Built-in to Node.js)
```cmd
corepack enable
corepack prepare pnpm@latest --activate
```

---

## ⚡ Command Cheatsheet (NPM vs PNPM)

| Action | NPM Command | PNPM Equivalent |
| :--- | :--- | :--- |
| **Install all dependencies** | `npm install` | `pnpm install` (or `pnpm i`) |
| **Add dependency** | `npm install <pkg>` | `pnpm add <pkg>` |
| **Add dev dependency** | `npm install -D <pkg>` | `pnpm add -D <pkg>` |
| **Add global dependency** | `npm install -g <pkg>` | `pnpm add -g <pkg>` |
| **Remove dependency** | `npm uninstall <pkg>` | `pnpm remove <pkg>` (or `pnpm rm`) |
| **Run script** | `npm run <script>` | `pnpm <script>` or `pnpm run <script>` |
| **Execute binary / runner** | `npx <pkg>` / `npm exec <pkg>` | `pnpm dlx <pkg>` or `pnpm exec <pkg>` |
| **Update dependencies** | `npm update` | `pnpm update` (or `pnpm up`) |
| **Check outdated packages** | `npm outdated` | `pnpm outdated` |
| **Security audit** | `npm audit` | `pnpm audit` |
| **Initialize package.json** | `npm init -y` | `pnpm init` |

---

## 💻 Working with Projects

### 1. Initializing a New Project
```bash
pnpm init
```

### 2. Installing Packages
```bash
# Add a production package
pnpm add express

# Add a development package
pnpm add -D typescript @types/node

# Add specific version
pnpm add lodash@4.17.21
```

### 3. Running Scripts
Notice that with `pnpm`, you can omit the `run` keyword for standard scripts!
```bash
pnpm dev
pnpm build
pnpm start
```

---

## 🏗️ Monorepo & Workspaces

`pnpm` has native built-in support for multi-package repositories (monorepos) without requiring additional tools like Lerna.

Create a `pnpm-workspace.yaml` in the root:
```yaml
packages:
  - 'packages/*'
  - 'apps/*'
```

Run commands across specific packages:
```bash
# Run build only on the 'web' package
pnpm --filter web build

# Add a shared dependency to all packages
pnpm --filter "./packages/*" add dayjs
```

---

## 🛡️ Best Practices

1. **Commit `pnpm-lock.yaml`**: Always commit `pnpm-lock.yaml` to Git. Do not generate or mix with `package-lock.json`.
2. **Configure `.npmrc`**: You can add an `.npmrc` file to set project preferences:
   ```ini
   auto-install-peers=true
   strict-peer-dependencies=false
   ```
3. **Avoid Phantom Dependencies**: If code requires `dotenv` or `axios`, make sure it is listed in `package.json`, even if another library depends on it.
4. **Clean Cache**: If you ever need to prune or verify global store integrity:
   ```bash
   pnpm store prune
   ```
