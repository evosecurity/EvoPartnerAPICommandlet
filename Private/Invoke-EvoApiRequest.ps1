function Invoke-EvoApiRequest {
    <#
    .SYNOPSIS
        Internal helper to invoke Evo Partner API HTTP requests.

    .DESCRIPTION
        Builds the request URI from the configured BaseUri and relative Path, adds
        authentication headers, serializes the request body as JSON when provided,
        and calls Invoke-RestMethod. Errors are surfaced as terminating errors so
        that callers can use try/catch.

    .PARAMETER Method
        HTTP method to use (GET, POST, PUT, DELETE).

    .PARAMETER Path
        Relative API path, e.g. '/v1/users'.

    .PARAMETER Query
        Optional hashtable of query-string parameters. Array values are expanded
        as repeated keys, which works with parameters like 'tenantIds[]'.

    .PARAMETER Body
        Optional PowerShell object to be serialized to JSON and used as the
        request body.

    .PARAMETER ApiKey
        Optional override API key. When not provided, the value from the
        module configuration is used.

    .PARAMETER BaseUri
        Optional override for the API base URI. When not provided, the value
        from the module configuration is used.

    .OUTPUTS
        The deserialized JSON response from Invoke-RestMethod.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('GET','POST','PUT','DELETE')]
        [string]$Method,

        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter()]
        [hashtable]$Query,

        [Parameter()]
        [object]$Body,

        [Parameter()]
        [string]$ApiKey,

        [Parameter()]
        [string]$BaseUri
    )

    if (-not $BaseUri) {
        $BaseUri = $script:EvoPartnerApiConfig.BaseUri
    }

    if (-not $BaseUri) {
        throw "Evo Partner API base URI is not configured. Use Set-EvoPartnerApiConfig to set it."
    }

    $uriBuilder = [System.UriBuilder]::new($BaseUri.TrimEnd('/'))
    $relativePath = $Path.TrimStart('/')
    if ($uriBuilder.Path.EndsWith('/')) {
        $uriBuilder.Path = $uriBuilder.Path + $relativePath
    } else {
        $uriBuilder.Path = $uriBuilder.Path + '/' + $relativePath
    }

    if ($Query) {
        $pairs = New-Object System.Collections.Generic.List[string]
        foreach ($key in $Query.Keys) {
            $value = $Query[$key]
            if ($null -eq $value) { continue }

            if ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
                foreach ($item in $value) {
                    $pairs.Add(("{0}={1}" -f [uri]::EscapeDataString($key), [uri]::EscapeDataString("$item")))
                }
            } else {
                $pairs.Add(("{0}={1}" -f [uri]::EscapeDataString($key), [uri]::EscapeDataString("$value")))
            }
        }

        if ($pairs.Count -gt 0) {
            $uriBuilder.Query = $pairs -join '&'
        }
    }

    $finalUri = $uriBuilder.Uri.AbsoluteUri

    if (-not $ApiKey) {
        $ApiKey = $script:EvoPartnerApiConfig.ApiKey
    }

    $headers = @{
        'Accept' = 'application/json'
    }

    if ($ApiKey) {
        $headers['Authorization'] = "Bearer $ApiKey"
    } else {
        throw "Evo Partner API key is not configured. Use Set-EvoPartnerApiConfig to set it or pass -ApiKey explicitly."
    }

    $invokeParams = @{
        Method      = $Method
        Uri         = $finalUri
        Headers     = $headers
        ErrorAction = 'Stop'
    }

    if ($PSBoundParameters.ContainsKey('Body') -and $null -ne $Body) {
        $json = $Body | ConvertTo-Json -Depth 10
        $invokeParams['Body'] = $json
        $invokeParams['ContentType'] = 'application/json'
    }

    $maxAttempts = 3
    $attempt = 0

    while ($true) {
        $attempt++
        try {
            return Invoke-RestMethod @invokeParams
        }
        catch {
            $ex = $_.Exception
            $response = $null
            $statusCode = $null
            $statusDescription = $null
            $rateLimitLimit = $null
            $rateLimitRemaining = $null
            $rateLimitReset = $null
            $retryAfterSeconds = $null

            if ($ex.PSObject.Properties['Response']) {
                $response = $ex.Response

                if ($response -and $response.PSObject.Properties['StatusCode']) {
                    $statusCode = [int]$response.StatusCode
                }
                if ($response -and $response.PSObject.Properties['StatusDescription']) {
                    $statusDescription = $response.StatusDescription
                }

                if ($response -and $response.PSObject.Properties['Headers']) {
                    $headersObj = $response.Headers
                    $rateLimitLimit = $headersObj['RateLimit-Limit']
                    $rateLimitRemaining = $headersObj['RateLimit-Remaining']
                    $rateLimitReset = $headersObj['RateLimit-Reset']

                    $retryAfterHeader = $headersObj['Retry-After']
                    if ($retryAfterHeader) {
                        [int]$seconds = 0
                        if ([int]::TryParse($retryAfterHeader, [ref]$seconds)) {
                            $retryAfterSeconds = $seconds
                        }
                    }
                }
            }

            if ($statusCode -eq 429 -and $script:EvoPartnerApiConfig.RetryOnRateLimit -and $attempt -lt $maxAttempts) {
                if (-not $retryAfterSeconds -and $rateLimitReset) {
                    [int]$resetSeconds = 0
                    if ([int]::TryParse($rateLimitReset, [ref]$resetSeconds)) {
                        $retryAfterSeconds = $resetSeconds
                    }
                }

                if (-not $retryAfterSeconds) {
                    $retryAfterSeconds = 5
                }

                Start-Sleep -Seconds $retryAfterSeconds
                continue
            }

            $rateLimitInfo = ''
            if ($rateLimitLimit -or $rateLimitRemaining -or $rateLimitReset) {
                $rateLimitInfo = " RateLimit-Limit=$rateLimitLimit; RateLimit-Remaining=$rateLimitRemaining; RateLimit-Reset=$rateLimitReset."
            }

            $statusInfo = ''
            if ($statusCode) {
                $statusInfo = " HTTP $statusCode $statusDescription."
            }

            $errorBodyInfo = ''
            if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
                $rawError = $_.ErrorDetails.Message
                $parsedError = $null
                try {
                    $parsedError = $rawError | ConvertFrom-Json -ErrorAction SilentlyContinue
                }
                catch {
                }

                if ($parsedError) {
                    $apiMessage = $parsedError.message
                    $apiCode = $parsedError.code
                    if ($apiMessage -or $apiCode) {
                        $errorBodyInfo = " API ErrorCode=$apiCode Message=$apiMessage."
                    }
                }
                elseif ($rawError) {
                    $errorBodyInfo = " API Error=$rawError."
                }
            }

            $message = "Error calling Evo Partner API {0} {1}.{2}{3}{4} {5}" -f $Method, $finalUri, $statusInfo, $rateLimitInfo, $errorBodyInfo, $ex.Message
            throw (New-Object System.Exception($message, $ex))
        }
    }
}
