# Setup Script for Git, Node.js, and PNPM (Supports Online & Offline Localized Installation)
Param(
    [switch]$NonInteractive
)

$ErrorActionPreference = 'Continue'
$scriptDir = $PSScriptRoot
$depsDir = Join-Path $scriptDir 'deps'

if (-not (Test-Path $depsDir)) {
    New-Item -ItemType Directory -Path $depsDir -Force | Out-Null
}

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "       Environment Setup (Git, Node.js, pnpm)           " -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan

# 1. Test Network Connectivity
Write-Host "`n[1/5] Checking network connectivity..." -ForegroundColor Yellow
$isOnline = $false
try {
    $request = [System.Net.WebRequest]::Create("https://1.1.1.1")
    $request.Timeout = 3000
    $response = $request.GetResponse()
    $response.Close()
    $isOnline = $true
} catch {
    $isOnline = $false
}

$useOnline = $false
if ($isOnline) {
    Write-Host "-> Network status: ONLINE" -ForegroundColor Green
    if (-not $NonInteractive) {
        $answer = Read-Host "Network detected! Would you like to check and download the latest installer packages from the internet? [Y/N] (Default: N)"
        if ($answer -match "^[Yy]$") {
            $useOnline = $true
        }
    }
} else {
    Write-Host "-> Network status: OFFLINE (Using localized dependencies from .\deps)" -ForegroundColor DarkYellow
}

# Download updates if requested
if ($useOnline) {
    Write-Host "`nDownloading latest installers to .\deps..." -ForegroundColor Cyan
    try {
        Write-Host "Downloading Git installer..."
        & curl.exe -sSL -o (Join-Path $depsDir "Git-installer.exe") "https://github.com/git-for-windows/git/releases/download/v2.48.1.windows.1/Git-2.48.1-64-bit.exe"
        
        Write-Host "Downloading Node.js LTS installer..."
        & curl.exe -sSL -o (Join-Path $depsDir "node-installer.msi") "https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi"
        
        Write-Host "Downloading pnpm binary..."
        $zipFile = Join-Path $depsDir "pnpm.zip"
        & curl.exe -sSL -o $zipFile "https://github.com/pnpm/pnpm/releases/download/v11.22.0/pnpm-win32-x64.zip"
        Expand-Archive -Path $zipFile -DestinationPath $depsDir -Force
        Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
        
        Write-Host "Latest installers successfully downloaded!" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download online packages ($($_)). Falling back to localized dependencies in .\deps." -ForegroundColor Red
    }
}

# Update PATH helper function
function Add-ToPath($targetPath) {
    if (-not (Test-Path $targetPath)) { return }
    $currentProcessPath = $env:Path
    if ($currentProcessPath -notlike "*$targetPath*") {
        $env:Path = "$targetPath;$env:Path"
    }
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$targetPath*") {
        [Environment]::SetEnvironmentVariable("Path", "$targetPath;$userPath", "User")
        Write-Host "Added '$targetPath' to User PATH environment variable." -ForegroundColor Cyan
    }
}

# 2. Setup Git
Write-Host "`n[2/5] Checking Git installation..." -ForegroundColor Yellow
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCmd -and (Test-Path "C:\Program Files\Git\cmd\git.exe")) {
    Add-ToPath "C:\Program Files\Git\cmd"
    $gitCmd = Get-Command git -ErrorAction SilentlyContinue
}

if ($gitCmd) {
    $gitVer = & git --version
    Write-Host "-> Git is already installed: $gitVer" -ForegroundColor Green
} else {
    $gitInstaller = Join-Path $depsDir "Git-installer.exe"
    if (Test-Path $gitInstaller) {
        Write-Host "Installing Git from localized installer..." -ForegroundColor Cyan
        Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP-" -Wait
        Add-ToPath "C:\Program Files\Git\cmd"
        Write-Host "Git installation complete!" -ForegroundColor Green
    } else {
        Write-Host "Error: Git installer not found in $gitInstaller" -ForegroundColor Red
    }
}

# 3. Setup Node.js & npm
Write-Host "`n[3/5] Checking Node.js installation..." -ForegroundColor Yellow
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCmd -and (Test-Path "C:\Program Files\nodejs\node.exe")) {
    Add-ToPath "C:\Program Files\nodejs"
    $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
}

if ($nodeCmd) {
    $nodeVer = & node -v
    $npmVer = & npm -v
    Write-Host "-> Node.js is already installed: $nodeVer (npm $npmVer)" -ForegroundColor Green
} else {
    $nodeMsi = Join-Path $depsDir "node-installer.msi"
    if (Test-Path $nodeMsi) {
        Write-Host "Installing Node.js LTS from localized installer..." -ForegroundColor Cyan
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$nodeMsi`" /qb /norestart" -Wait
        Add-ToPath "C:\Program Files\nodejs"
        Write-Host "Node.js installation complete!" -ForegroundColor Green
    } else {
        Write-Host "Error: Node.js installer not found in $nodeMsi" -ForegroundColor Red
    }
}

# 4. Setup pnpm
Write-Host "`n[4/5] Setting up pnpm..." -ForegroundColor Yellow

$pnpmTargetDir = Join-Path $env:LocalAppData "pnpm"
if (-not (Test-Path $pnpmTargetDir)) {
    New-Item -ItemType Directory -Path $pnpmTargetDir -Force | Out-Null
}

$localPnpmExe = Join-Path $pnpmTargetDir "pnpm.exe"
$depPnpmExe = Join-Path $depsDir "pnpm.exe"

if (Test-Path $depPnpmExe) {
    Copy-Item -Path $depPnpmExe -Destination $localPnpmExe -Force
}

Add-ToPath $pnpmTargetDir

$pnpmCmd = Get-Command pnpm -ErrorAction SilentlyContinue
if ($pnpmCmd) {
    $pnpmVer = & pnpm -v
    Write-Host "-> pnpm is set up and ready: v$pnpmVer" -ForegroundColor Green
} elseif (Test-Path $localPnpmExe) {
    Write-Host "Notice: Executing pnpm binary directly from $localPnpmExe" -ForegroundColor Cyan
    & "$localPnpmExe" --version
}

# 5. Verification Summary
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "               Installation Verification                 " -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan

$gitInstalled = Get-Command git -ErrorAction SilentlyContinue
$nodeInstalled = Get-Command node -ErrorAction SilentlyContinue
$npmInstalled = Get-Command npm -ErrorAction SilentlyContinue
$pnpmInstalled = Get-Command pnpm -ErrorAction SilentlyContinue

Write-Host "Git:  " -NoNewline
if ($gitInstalled) { Write-Host (& git --version) -ForegroundColor Green } else { Write-Host "Not found" -ForegroundColor Red }

Write-Host "Node: " -NoNewline
if ($nodeInstalled) { Write-Host (& node -v) -ForegroundColor Green } else { Write-Host "Not found" -ForegroundColor Red }

Write-Host "npm:  " -NoNewline
if ($npmInstalled) { Write-Host ("v" + (& npm -v)) -ForegroundColor Green } else { Write-Host "Not found" -ForegroundColor Red }

Write-Host "pnpm: " -NoNewline
if ($pnpmInstalled) { Write-Host ("v" + (& pnpm -v)) -ForegroundColor Green } else { Write-Host "Not found" -ForegroundColor Red }

Write-Host "`nSetup completed! Refer to 'pnpm_guide.md' for usage instructions." -ForegroundColor Green
