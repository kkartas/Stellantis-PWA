param(
    [string]$PythonExe = "",
    [string]$HandlerPath = "",
    [switch]$UsePythonw = $true
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($PythonExe)) {
    $PythonExe = (Get-Command python -ErrorAction Stop).Source
}

if ($UsePythonw) {
    $pythonw = Join-Path (Split-Path $PythonExe -Parent) "pythonw.exe"
    if (Test-Path $pythonw) {
        $PythonExe = $pythonw
    }
}

if ([string]::IsNullOrWhiteSpace($HandlerPath)) {
    $HandlerPath = Join-Path $PSScriptRoot "windows_mymap_handler.py"
}

if (-not (Test-Path $HandlerPath)) {
    throw "Handler file not found: $HandlerPath"
}

$protocolKey = "HKCU:\Software\Classes\mymap"
$commandKey = "$protocolKey\shell\open\command"
$iconKey = "$protocolKey\DefaultIcon"

New-Item -Path $protocolKey -Force | Out-Null
Set-ItemProperty -Path $protocolKey -Name "(default)" -Value "URL:mymap Protocol"
New-ItemProperty -Path $protocolKey -Name "URL Protocol" -Value "" -PropertyType String -Force | Out-Null

New-Item -Path $iconKey -Force | Out-Null
Set-ItemProperty -Path $iconKey -Name "(default)" -Value "`"$PythonExe`",0"

New-Item -Path $commandKey -Force | Out-Null
$command = "`"$PythonExe`" `"$HandlerPath`" `"%1`""
Set-ItemProperty -Path $commandKey -Name "(default)" -Value $command

Write-Host "Registered protocol handler for mymap://" -ForegroundColor Green
Write-Host "Command: $command"
Write-Host ""
Write-Host "Optional env overrides (System/User):" -ForegroundColor Yellow
Write-Host "  PSACC_OAUTH_API_URL (default: http://127.0.0.1:5000/api/setup/oauth)"
Write-Host "  PSACC_UI_URL        (default: http://127.0.0.1:5000/)"
Write-Host "  PSACC_HANDLER_SHOW_UI=1 to enable popup messages"

