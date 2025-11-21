function Test-EvoPartnerApiHealth {
    <#
    .SYNOPSIS
        Test connectivity and basic health of the Evo Partner API.

    .DESCRIPTION
        Calls the /v1/health endpoint of the Evo Partner API using the
        current configuration. Returns the deserialized response from
        the API (typically an object with a Status property), or throws
        a terminating error if the request fails.

    .EXAMPLE
        Test-EvoPartnerApiHealth

        Tests connectivity using the configured BaseUri and ApiKey and
        returns the API health status.
    #>
    [CmdletBinding()]
    param()

    $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/health'
    return $response
}
