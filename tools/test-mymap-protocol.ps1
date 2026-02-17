param(
    [string]$Code = "TEST_CODE_FROM_PROTOCOL"
)

$uri = "mymap://oauth2redirect?code=$Code&scope=openid%20profile"
Write-Host "Launching protocol URI:"
Write-Host "  $uri"
Start-Process $uri

