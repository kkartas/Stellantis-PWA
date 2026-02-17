$ErrorActionPreference = "Stop"

$protocolKey = "HKCU:\Software\Classes\mymap"
if (Test-Path $protocolKey) {
    Remove-Item -Path $protocolKey -Recurse -Force
    Write-Host "Removed protocol handler: mymap://" -ForegroundColor Green
} else {
    Write-Host "Protocol handler was not registered in HKCU." -ForegroundColor Yellow
}

