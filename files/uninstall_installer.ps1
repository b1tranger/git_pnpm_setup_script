# Uninstallation Script for Git, Node.js, and PNPM
Param(
    [switch]$NonInteractive
)

$ErrorActionPreference = 'Continue'
$scriptDir = $PSScriptRoot
$depsDir = Join-Path $scriptDir 'deps'

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "       Environment Uninstall (Git, Node.js, pnpm)       " -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan

if (-not $NonInteractive) {
    $confirm = Read-Host "`nAre you sure you want to uninstall Git, Node.js, and pnpm from this system? [Y/N] (Default: N)"
    if ($confirm -notmatch "^[Yy]$") {
        Write-Host "Uninstallation cancelled by user." -ForegroundColor Yellow
        exit 0
    }
}

# Helper function to remove directory from PATH environment variables
function Remove-FromPath($targetPath) {
    if ([string]::IsNullOrWhiteSpace($targetPath)) { return }
    $cleanTargetPath = $targetPath.TrimEnd('\').TrimEnd('/')
    
    # 1. Update current process PATH
    $processPaths = ($env:Path -split ';') | Where-Object { 
        [string]::IsNullOrWhiteSpace($_) -eq $false -and $_.TrimEnd('\').TrimEnd('/') -ne $cleanTargetPath 
    }
    $env:Path = ($processPaths -join ';')
    
    # 2. Update User environment PATH
    $userPathRaw = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPathRaw) {
        $userPaths = ($userPathRaw -split ';') | Where-Object { 
            [string]::IsNullOrWhiteSpace($_) -eq $false -and $_.TrimEnd('\').TrimEnd('/') -ne $cleanTargetPath 
        }
        $newUserPath = ($userPaths -join ';')
        [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
        Write-Host "Removed '$targetPath' from User PATH environment variable." -ForegroundColor Cyan
    }
}

# 1. Uninstall pnpm
Write-Host "`n[1/4] Uninstalling pnpm..." -ForegroundColor Yellow
$pnpmTargetDir = Join-Path $env:LocalAppData "pnpm"
if (Test-Path -LiteralPath $pnpmTargetDir) {
    try {
        Remove-Item -LiteralPath $pnpmTargetDir -Recurse -Force -ErrorAction Stop
        Write-Host "Removed pnpm directory: $pnpmTargetDir" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not fully delete $pnpmTargetDir. ($($_))" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "-> pnpm directory not found." -ForegroundColor Gray
}
Remove-FromPath $pnpmTargetDir

# Clean PNPM_HOME environment variable
$env:PNPM_HOME = $null
[Environment]::SetEnvironmentVariable("PNPM_HOME", $null, "User")

# 2. Uninstall Node.js
Write-Host "`n[2/4] Uninstalling Node.js..." -ForegroundColor Yellow
$nodeMsi = Join-Path $depsDir "node-installer.msi"
$nodeUninstalled = $false

if (Test-Path -LiteralPath $nodeMsi) {
    Write-Host "Running silent uninstallation for Node.js..." -ForegroundColor Cyan
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/x `"$nodeMsi`" /qb /norestart" -Wait
    $nodeUninstalled = $true
} else {
    # Query registry for Node.js uninstall key
    $nodeRegKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like "*Node.js*" } | Select-Object -First 1
        
    if (-not $nodeRegKey) {
        $nodeRegKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "*Node.js*" } | Select-Object -First 1
    }
    
    if ($nodeRegKey -and $nodeRegKey.UninstallString) {
        Write-Host "Found Node.js in Registry. Uninstalling..." -ForegroundColor Cyan
        $uninstallCmd = $nodeRegKey.UninstallString
        if ($uninstallCmd -match "msiexec") {
            $guid = ($uninstallCmd -split '\{')[1]
            if ($guid) {
                $guid = "{$($guid.Split('}')[0])}"
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $guid /qb /norestart" -Wait
                $nodeUninstalled = $true
            }
        }
    }
}

if ($nodeUninstalled) {
    Write-Host "Node.js uninstallation complete." -ForegroundColor Green
} else {
    Write-Host "Node.js installer or registry entry not found." -ForegroundColor Gray
}
Remove-FromPath "C:\Program Files\nodejs"
Remove-FromPath (Join-Path $env:AppData "npm")

# 3. Uninstall Git
Write-Host "`n[3/4] Uninstalling Git..." -ForegroundColor Yellow
$gitUninstaller = "C:\Program Files\Git\unins000.exe"
$gitUninstalled = $false

if (Test-Path -LiteralPath $gitUninstaller) {
    Write-Host "Running silent uninstallation for Git..." -ForegroundColor Cyan
    Start-Process -FilePath $gitUninstaller -ArgumentList "/VERYSILENT /NORESTART /SUPPRESSMSGBOXES" -Wait
    $gitUninstalled = $true
} else {
    # Query Registry for Git
    $gitRegKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like "*Git*" } | Select-Object -First 1
    if (-not $gitRegKey) {
        $gitRegKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "*Git*" } | Select-Object -First 1
    }
    if ($gitRegKey -and $gitRegKey.UninstallString) {
        $unString = $gitRegKey.UninstallString.Replace('"','')
        if (Test-Path -LiteralPath $unString) {
            Start-Process -FilePath $unString -ArgumentList "/VERYSILENT /NORESTART /SUPPRESSMSGBOXES" -Wait
            $gitUninstalled = $true
        }
    }
}

if ($gitUninstalled) {
    Write-Host "Git uninstallation complete." -ForegroundColor Green
} else {
    Write-Host "Git uninstaller not found." -ForegroundColor Gray
}
Remove-FromPath "C:\Program Files\Git\cmd"
Remove-FromPath "C:\Program Files\Git\bin"
Remove-FromPath "C:\Program Files\Git\mingw64\bin"

# 4. Verification Summary
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "              Uninstallation Verification                " -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan

$gitCmd = Get-Command git -ErrorAction SilentlyContinue
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
$npmCmd = Get-Command npm -ErrorAction SilentlyContinue
$pnpmCmd = Get-Command pnpm -ErrorAction SilentlyContinue

Write-Host "Git:  " -NoNewline
if (-not $gitCmd) { Write-Host "Uninstalled (Not found)" -ForegroundColor Green } else { Write-Host "Still present" -ForegroundColor Red }

Write-Host "Node: " -NoNewline
if (-not $nodeCmd) { Write-Host "Uninstalled (Not found)" -ForegroundColor Green } else { Write-Host "Still present" -ForegroundColor Red }

Write-Host "npm:  " -NoNewline
if (-not $npmCmd) { Write-Host "Uninstalled (Not found)" -ForegroundColor Green } else { Write-Host "Still present" -ForegroundColor Red }

Write-Host "pnpm: " -NoNewline
if (-not $pnpmCmd) { Write-Host "Uninstalled (Not found)" -ForegroundColor Green } else { Write-Host "Still present" -ForegroundColor Red }

Write-Host "`nUninstallation process finished." -ForegroundColor Green
