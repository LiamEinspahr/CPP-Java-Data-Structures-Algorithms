#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

# We need to check for a few things before running the Dockerfile
# 1. WSL
# 2. Docker Desktop
# 3. Git
# 4. VSCode

# Check the Uninstall entries, since each installed
# program also tells Windows how to remove them later
$uninstallPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',             # 64-bit, all users
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', # 32-bit, all users
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'              # per-user installs
)

# The keywords to search for in the entries
$searchWSL    = 'Windows Subsystem for Linux'
$searchDocker = 'Docker Desktop'
$searchGit    = 'Git'
$searchVSCode = 'Microsoft Visual Studio Code*'

# Iteratively check for the installs with a PowerShell function
function Test-Installed {
    param([string]$Pattern)

    $found = Get-ItemProperty $uninstallPaths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like $Pattern }

    return [bool]$found
}

# 1. Handle Git Installation
if (-not (Test-Installed $searchGit)) {
    Write-Host "Git not found in uninstall entries. Downloading and installing automatically..." -ForegroundColor Cyan
    # Using the direct official standalone download link for the installer
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements --silent
    if ($LASTEXITCODE -ne 0) { throw "Git install failed (exit code $LASTEXITCODE)" }
    Write-Host "Git installed successfully." -ForegroundColor Green
} else {
    Write-Host "Git is already installed." -ForegroundColor Green
}

# 2. Handle WSL Installation
if (-not (Test-Installed $searchWSL)) {
    Write-Host "WSL not found in uninstall entries. Installing default Ubuntu distro..." -ForegroundColor Cyan
    # --no-launch prevents it from opening a separate bash terminal mid-script
    wsl --install --no-launch
    if ($LASTEXITCODE -ne 0) { throw "WSL install failed (exit code $LASTEXITCODE)" }
    Write-Host "WSL installation complete. A system reboot will be required." -ForegroundColor Yellow
} else {
    Write-Host "WSL is already installed." -ForegroundColor Green
}

# 3. Handle Docker Desktop Installation
if (-not (Test-Installed $searchDocker)) {
    Write-Host "Docker Desktop not found in uninstall entries. Installing via winget..." -ForegroundColor Cyan
    # Utilizing winget for silent background deployment of Docker Desktop
    winget install --id Docker.DockerDesktop -e --source winget --accept-package-agreements --accept-source-agreements --silent
    if ($LASTEXITCODE -ne 0) { throw "Docker Desktop install failed (exit code $LASTEXITCODE)" }
    Write-Host "Docker Desktop installed successfully." -ForegroundColor Green
} else {
    Write-Host "Docker Desktop is already installed." -ForegroundColor Green
}

# 4. Handle Visual Studio Code Installation
if (-not (Test-Installed $searchVSCode)) {
    Write-Host "Visual Studio Code not found in uninstall entries. Installing via winget..." -ForegroundColor Cyan
    winget install --id Microsoft.VisualStudioCode -e --source winget --accept-package-agreements --accept-source-agreements --silent
    if ($LASTEXITCODE -ne 0) { throw "Visual Studio Code install failed (exit code $LASTEXITCODE)" }
    Write-Host "Visual Studio Code installed successfully." -ForegroundColor Green
} else {
    Write-Host "Visual Studio Code is already installed." -ForegroundColor Green
}

Write-Host "`nAll dependency checks complete!" -ForegroundColor Green