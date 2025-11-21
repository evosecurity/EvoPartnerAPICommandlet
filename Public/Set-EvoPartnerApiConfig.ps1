function Set-EvoPartnerApiConfig {
    <#
    .SYNOPSIS
        Configure the Evo Partner API connection settings for this session.

    .DESCRIPTION
        Sets the base URI, API key, default page size, and optional
        rate-limit retry behavior used by all EvoPartnerAPICommandlet
        cmdlets. Settings are stored in-memory for the current PowerShell
        session.

    .PARAMETER ApiKey
        The Evo Partner API key to use for bearer authentication.

    .PARAMETER BaseUri
        The base URI for the Evo Partner API. Defaults to
        https://partner-api.evosecurity.com if not specified.

    .PARAMETER DefaultPageSize
        Default page size to use for paginated list operations when a
        cmdlet does not specify an explicit -Limit.

    .PARAMETER RetryOnRateLimit
        When specified, enables simple automatic retries for HTTP 429
        responses based on the server-provided retry-after hints.

    .PARAMETER Clear
        Reset all configuration values back to their defaults and clear
        the API key.

    .EXAMPLE
        Set-EvoPartnerApiConfig -ApiKey 'xxxxxxxx' -DefaultPageSize 50

        Configure the module to use the provided API key and a default
        page size of 50 items.
    #>
    [CmdletBinding(SupportsShouldProcess = $false)]
    param(
        [Parameter()]
        [string]$ApiKey,

        [Parameter()]
        [string]$BaseUri,

        [Parameter()]
        [ValidateRange(1, 1000)]
        [int]$DefaultPageSize,

        [Parameter()]
        [switch]$RetryOnRateLimit,

        [Parameter()]
        [switch]$Clear
    )

    if ($Clear.IsPresent) {
        $script:EvoPartnerApiConfig = [ordered]@{
            BaseUri          = 'https://partner-api.evosecurity.com'
            ApiKey           = $null
            DefaultPageSize  = 20
            RetryOnRateLimit = $false
        }
        return
    }

    if ($PSBoundParameters.ContainsKey('BaseUri')) {
        if (-not [uri]::IsWellFormedUriString($BaseUri, [System.UriKind]::Absolute)) {
            throw "BaseUri '$BaseUri' is not a valid absolute URI."
        }
        $script:EvoPartnerApiConfig.BaseUri = $BaseUri
    }

    if ($PSBoundParameters.ContainsKey('ApiKey')) {
        if ([string]::IsNullOrWhiteSpace($ApiKey)) {
            throw 'ApiKey cannot be null or empty.'
        }
        $script:EvoPartnerApiConfig.ApiKey = $ApiKey
    }

    if ($PSBoundParameters.ContainsKey('DefaultPageSize')) {
        $script:EvoPartnerApiConfig.DefaultPageSize = $DefaultPageSize
    }

    if ($PSBoundParameters.ContainsKey('RetryOnRateLimit')) {
        $script:EvoPartnerApiConfig.RetryOnRateLimit = [bool]$RetryOnRateLimit
    }
}
