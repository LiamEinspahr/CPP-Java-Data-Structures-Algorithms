# Looks up a program in the uninstall registry and returns its install folder to re-verify docker installation
function Get-InstallLocation {
    param(
        [Parameter(Mandatory)]
        [string]$DisplayName
    )

    # Every installed program registers an uninstall entry in one of these places
    $uninstallPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',             # 64-bit, all users
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', # 32-bit, all users
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'              # per-user installs
    )

    # Read every entry, keep the ones whose name matches
    $entry = Get-ItemProperty $uninstallPaths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like $DisplayName } |
        Select-Object -First 1 #pass the first entry back

    # Not installed, or installed but no folder recorded (WSL does this)
    if (-not $entry -or -not $entry.InstallLocation) {
        return $null
    }

    return $entry.InstallLocation
}
 
function Confirm-DockerRunning {
    param(
        [Parameter(Mandatory)]
        [string]$ProcessName
    )

    if(Get-Process $ProcessName) {
        Write-Host "Found Docker Desktop Process~" -ForegroundColor Green
        return($true)
    }

    Write-Host "Couldn't find running Docker Desktop process..." -ForegroundColor Red
    return($false)
}

function Test-DockerEngine { # Test to see if the process generates the minimum amount of info needed to confirm its up and running
    docker info *> $null
    return ($LASTEXITCODE -eq 0)
}

function Wait-DockerEngine {
    param(
        [int]$TimeoutSeconds = 120   # optional, defaults to 2 minutes
    )

    $currentWaitedTime = 0
    while (-not (Test-DockerEngine)) {
        if ($currentWaitedTime -ge $TimeoutSeconds) {
            return $false            # gave up; caller decides what to do
        }
        Start-Sleep -Seconds 3
        $currentWaitedTime += 3
    }
    return $true                     # engine is answering
}

# First re-verify Docker Desktop installation
$dockerDir = Get-InstallLocation -DisplayName 'Docker Desktop'
$ImageName = "liam-cpp-java-ds-cicd-pipeline"

if (-not $dockerDir) {
    Write-Host "Docker Desktop is not installed. Run init_setup.ps1 first..." -ForegroundColor Red
    exit 1
}

# After verification, check if it is alrady running
if (-not (Confirm-DockerRunning -ProcessName "Docker Desktop")) {
    Write-Host 'Starting Docker Desktop~' -ForegroundColor Green
    Start-Process "$dockerDir/Docker Desktop.exe"

    if( -not (Wait-DockerEngine)) {
        Write-Host "Docker engine did not become ready..." -ForegroundColor Red
        exit 1
    }

    Write-Host "Docker engine is ready for use~" -ForegroundColor Green
}
else {
    Write-Host "Docker Desktop already running!" -ForegroundColor DarkYellow

    Write-Host ""
    if( -not (Wait-DockerEngine)) {
        Write-Host "Docker engine did not become ready..." -ForegroundColor Red
        exit 1
    }

    Write-Host 'Docker engine is ready~' -ForegroundColor Green
}

docker start $ImageName
docker wait $ImageName