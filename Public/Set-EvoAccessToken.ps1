function Set-EvoAccessToken {
    <#
    .SYNOPSIS
        Update an existing access token.

    .DESCRIPTION
        Updates an access token via the /v1/access_tokens/{id} endpoint.

        Note: For LDAP agent tokens, the ExpireAt parameter is ignored as these tokens
        never expire. You can still update Name and Active for LDAP agent tokens.

    .PARAMETER Id
        The ID of the access token to update.

    .PARAMETER Name
        New name for the token.

    .PARAMETER ExpireAt
        New expiration date/time for the token. Must be a future date.
        Ignored for LDAP agent tokens as they never expire.

    .PARAMETER Active
        Whether the token is active.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('AccessTokenId')]
        [string]$Id,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [datetime]$ExpireAt,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [bool]$Active
    )

    process {
        $body = @{}

        if ($PSBoundParameters.ContainsKey('Name')) {
            $body['name'] = $Name
        }

        if ($PSBoundParameters.ContainsKey('ExpireAt')) {
            $body['expireAt'] = $ExpireAt.ToString('o')
        }

        if ($PSBoundParameters.ContainsKey('Active')) {
            $body['active'] = $Active
        }

        if ($body.Count -eq 0) {
            Write-Verbose 'No updatable fields were provided.'
            return
        }

        if (-not $PSCmdlet.ShouldProcess("Access token $Id", 'Update')) {
            return
        }

        $path = "/v1/access_tokens/$Id"
        $response = Invoke-EvoApiRequest -Method 'PUT' -Path $path -Body $body

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
