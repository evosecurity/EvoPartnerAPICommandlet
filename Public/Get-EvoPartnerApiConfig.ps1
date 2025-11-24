function Get-EvoPartnerApiConfig {
    <#
    .SYNOPSIS
        Get the current Evo Partner API configuration used by this module.

    .DESCRIPTION
        Returns the in-memory configuration used by EvoPartnerAPICommandlet,
        including the base URI, default page size, and whether automatic
        rate-limit retries are enabled. The API key value is not printed to
        avoid accidental disclosure.

    .EXAMPLE
        Get-EvoPartnerApiConfig

        Returns the current configuration object.
    #>
    [CmdletBinding()]
    param()

    if (-not $script:EvoPartnerApiConfig) {
        $script:EvoPartnerApiConfig = [ordered]@{
            BaseUri          = 'https://partner-api.evosecurity.com'
            ApiKey           = $null
            DefaultPageSize  = 20
            RetryOnRateLimit = $false
        }
    }

    $configCopy = [ordered]@{}
    foreach ($key in $script:EvoPartnerApiConfig.Keys) {
        $configCopy[$key] = $script:EvoPartnerApiConfig[$key]
    }

    if ($configCopy.Contains('ApiKey') -and $configCopy['ApiKey']) {
        $configCopy['ApiKey'] = '[REDACTED]'
    }

    [pscustomobject]$configCopy
}
