# EvoPartnerAPICommandlet.psm1
# Core module script for the Evo Partner API PowerShell cmdlets.

# Script-scoped configuration for the Evo Partner API.
# This is modified via Set-EvoPartnerApiConfig and read via Get-EvoPartnerApiConfig.
$script:EvoPartnerApiConfig = [ordered]@{
    BaseUri          = 'https://partner-api.evosecurity.com'
    ApiKey           = $null
    DefaultPageSize  = 20
    RetryOnRateLimit = $false
}

# Apply environment variable defaults if present
if ($env:EVO_PARTNER_API_URL) {
    $script:EvoPartnerApiConfig.BaseUri = $env:EVO_PARTNER_API_URL
}

if ($env:EVO_PARTNER_API_KEY) {
    $script:EvoPartnerApiConfig.ApiKey = $env:EVO_PARTNER_API_KEY
}

# Load private helper functions first
$privatePath = Join-Path -Path $PSScriptRoot -ChildPath 'Private'
if (Test-Path -Path $privatePath) {
    Get-ChildItem -Path $privatePath -Filter '*.ps1' -ErrorAction SilentlyContinue |
        ForEach-Object { . $_.FullName }
}

# Load public functions
$publicPath = Join-Path -Path $PSScriptRoot -ChildPath 'Public'
$publicScripts = @()
if (Test-Path -Path $publicPath) {
    $publicScripts = Get-ChildItem -Path $publicPath -Filter '*.ps1' -ErrorAction SilentlyContinue
    $publicScripts | ForEach-Object { . $_.FullName }
}

# Export public functions (one function per file, name == file basename)
if ($publicScripts) {
    Export-ModuleMember -Function $publicScripts.BaseName
}
