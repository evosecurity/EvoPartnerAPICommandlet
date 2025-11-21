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

    $config = $script:EvoPartnerApiConfig.Clone()
    if ($config.Contains('ApiKey') -and $config.ApiKey) {
        $config.ApiKey = '[REDACTED]'
    }

    [pscustomobject]$config
}
