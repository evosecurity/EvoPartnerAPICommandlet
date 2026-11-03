function Set-EvoDeploymentToken {
    <#
    .SYNOPSIS
        Update an existing deployment token.

    .DESCRIPTION
        Updates a deployment token via the /v1/deployment_tokens/{id} endpoint.
        Only the parameters you pass change, and within -Settings only the keys
        you pass change. Endpoints already installed with the token are not
        affected. The tenant and directory cannot be changed.

    .PARAMETER Id
        The ID of the deployment token to update.

    .PARAMETER Name
        New name for the token.

    .PARAMETER Active
        Whether the token can enroll endpoints. Use $false to deactivate it
        without deleting it.

    .PARAMETER ExpireAt
        New expiry. Must be in the future.

    .PARAMETER NeverExpire
        Remove the token's expiry.

    .PARAMETER Settings
        Agent settings to change, as a hashtable. See New-EvoDeploymentToken for
        the keys.

    .EXAMPLE
        Set-EvoDeploymentToken -Id 'DEPLOYMENT_TOKEN_GUID' -Active $false

    .EXAMPLE
        Get-EvoDeploymentToken -Id 'DEPLOYMENT_TOKEN_GUID' | Set-EvoDeploymentToken -NeverExpire -Settings @{ uacExtension = $true }
    #>
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'ExpireAt')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('DeploymentTokenId')]
        [string]$Id,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [bool]$Active,

        [Parameter(ParameterSetName = 'ExpireAt')]
        [datetime]$ExpireAt,

        [Parameter(Mandatory = $true, ParameterSetName = 'NeverExpire')]
        [switch]$NeverExpire,

        [Parameter()]
        [hashtable]$Settings
    )

    process {
        $body = @{}

        if ($PSBoundParameters.ContainsKey('Name')) {
            $body['name'] = $Name
        }

        if ($PSBoundParameters.ContainsKey('Active')) {
            $body['active'] = $Active
        }

        if ($PSBoundParameters.ContainsKey('ExpireAt')) {
            $body['expireAt'] = $ExpireAt.ToUniversalTime().ToString('o')
        }

        if ($NeverExpire) {
            $body['expireAt'] = $null
        }

        if ($Settings -and $Settings.Count -gt 0) {
            $body['settings'] = $Settings
        }

        if ($body.Count -eq 0) {
            Write-Verbose 'No updatable fields were provided.'
            return
        }

        if (-not $PSCmdlet.ShouldProcess("Deployment token $Id", 'Update')) {
            return
        }

        $response = Invoke-EvoApiRequest -Method 'PUT' -Path "/v1/deployment_tokens/$Id" -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $token = $response.data
            if ($token -is [pscustomobject]) {
                $token.PSObject.TypeNames.Insert(0, 'Evo.DeploymentToken')
            }
            Write-Output $token
        }
        else {
            Write-Output $response
        }
    }
}
