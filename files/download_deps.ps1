$ErrorActionPreference = 'Stop'
$depsDir = Join-Path $PSScriptRoot 'deps'
if (-not (Test-Path $depsDir)) {
    New-Item -ItemType Directory -Path $depsDir -Force | Out-Null
}

Write-Host "Checking localized dependencies in: $depsDir"

$gitFile = Join-Path $depsDir 'Git-installer.exe'
if (-not (Test-Path $gitFile) -or (Get-Item $gitFile).Length -lt 1000000) {
    Write-Host "Downloading Git installer..."
    & curl.exe -sSL -o $gitFile "https://github.com/git-for-windows/git/releases/download/v2.48.1.windows.1/Git-2.48.1-64-bit.exe"
} else {
    Write-Host "Git-installer.exe is ready."
}

$nodeFile = Join-Path $depsDir 'node-installer.msi'
if (-not (Test-Path $nodeFile) -or (Get-Item $nodeFile).Length -lt 1000000) {
    Write-Host "Downloading Node.js LTS installer..."
    & curl.exe -sSL -o $nodeFile "https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi"
} else {
    Write-Host "node-installer.msi is ready."
}

$pnpmFile = Join-Path $depsDir 'pnpm.exe'
if (-not (Test-Path $pnpmFile) -or (Get-Item $pnpmFile).Length -lt 1000000) {
    Write-Host "Downloading pnpm binary..."
    $zipFile = Join-Path $depsDir 'pnpm.zip'
    & curl.exe -sSL -o $zipFile "https://github.com/pnpm/pnpm/releases/download/v11.22.0/pnpm-win32-x64.zip"
    Expand-Archive -Path $zipFile -DestinationPath $depsDir -Force
    Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "pnpm.exe is ready."
}

Write-Host "`nLocalized dependencies status:"
Get-ChildItem $depsDir | Select-Object Name, @{Name="Size (MB)"; Expression={[math]::Round($_.Length / 1MB, 2)}} | Format-Table -AutoSize
