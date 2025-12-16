function New-EvoAccessToken {
    <#
    .SYNOPSIS
        Create a new access token.

    .DESCRIPTION
        Creates a new access token via the /v1/access_tokens endpoint.

        Note: LDAP agent tokens (Type = 'ldap_agent') never expire. For these tokens,
        the ExpireAt parameter is ignored and the token will be created with no expiration.
        For endpoint_agent tokens, ExpireAt is required and must be a future date.

    .PARAMETER Name
        The name of the access token.

    .PARAMETER DirectoryId
        The directory ID associated with this token.

    .PARAMETER Type
        The type of the token: endpoint_agent or ldap_agent.
        - endpoint_agent: Requires ExpireAt parameter (token will expire)
        - ldap_agent: ExpireAt is ignored (token never expires)

    .PARAMETER ExpireAt
        Expiration date/time for the token. Required for endpoint_agent tokens.
        Ignored for ldap_agent tokens as they never expire.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$DirectoryId,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('endpoint_agent','ldap_agent')]
        [string]$Type,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [datetime]$ExpireAt
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Access token '$Name'", 'Create')) {
            return
        }

        $body = @{
            name        = $Name
            directoryId = $DirectoryId
        }

        if ($PSBoundParameters.ContainsKey('Type') -and $Type) {
            $body['type'] = $Type
        }

        if ($PSBoundParameters.ContainsKey('ExpireAt')) {
            $body['expireAt'] = $ExpireAt.ToString('o')
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/access_tokens' -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $token = $response.data
            if ($token -is [pscustomobject]) {
                $token.PSObject.TypeNames.Insert(0, 'Evo.AccessToken')
            }
            Write-Output $token
        }
        else {
            Write-Output $response
        }
    }
}
