# First, reverify docker is installed
$uninstallPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',             # 64-bit, all users
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', # 32-bit, all users
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'              # per-user installs
)


function Verify-Docker-Installed {
    $searchDocker = 'Docker Desktop'

    $found = Get-ItemProperty $uninstallPaths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like $searchDocker}

    return [bool]$found
}

if (-not (Verify-Docker-Installed)) {
    Write-Host "Docker not installed... aborting" -ForegroundColor Cyan
}
else {
    
    # Declare the information for the docker container

    $ContainerName = "liam-poc-pipeline-running"
    $ImageName = "liam-cpp-java-ds-cicd-pipeline"
    $PortMapping = "8080:80"
}
