$ErrorActionPreference = "Stop"

$repo = "NotNull92/unity-agent-cli"
$installDir = "$env:LOCALAPPDATA\\unity-agent-cli"
$exe = "$installDir\\unity-agent-cli.exe"

New-Item -ItemType Directory -Force -Path $installDir | Out-Null

$url = "https://github.com/$repo/releases/latest/download/unity-agent-cli-windows-amd64.exe"
Write-Host "Downloading unity-agent-cli for windows/amd64..."
Invoke-WebRequest -Uri $url -OutFile $exe -UseBasicParsing

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$installDir;$userPath", "User")
    $env:Path = "$installDir;$env:Path"
    Write-Host "Added $installDir to PATH (restart shell to apply)"
}

Write-Host "Installed unity-agent-cli to $exe"
& $exe version
