function New-EvoDeploymentToken {
    <#
    .SYNOPSIS
        Create a deployment token for a tenant.

    .DESCRIPTION
        Creates a deployment token via the /v1/deployment_tokens endpoint. The
        returned object's deploymentToken property holds the full token value;
        this is the only time it is returned, so store it now. Pass it to the
        agent installer together with environmentUrl.

        A tenant that has any non-default directory requires -DirectoryId, and
        the directory must belong to the tenant. The tenant and directory cannot
        be changed after creation.

    .PARAMETER Name
        The name of the deployment token.

    .PARAMETER TenantId
        The tenant the token enrolls endpoints into.

    .PARAMETER DirectoryId
        One of the tenant's directories. Required when the tenant has a
        non-default directory.

    .PARAMETER Active
        Whether the token can enroll endpoints. Defaults to true.

    .PARAMETER ExpireAt
        When the token stops enrolling new endpoints. Must be in the future.
        Omit for a token that never expires.

    .PARAMETER Settings
        Agent settings applied to endpoints installed with this token, as a
        hashtable. Omitted keys take the portal defaults
        (preventElevatedLoginsRdp = $true, authenticationMode = 'both',
        everything else off). Keys: enableElevation, requireElevationForAdmins,
        enableJit, forceEvoLogin, preventElevatedLoginsRdp, authenticationMode
        ('both', 'elevation' or 'end_user'), mfaGracePeriod, failsafeUser,
        rememberLastUsername, uacExtension, uacExtensionAdminOnly,
        disableEvoLogin, disableEvoUac, unlimitedExtendedUacSession,
        persistentRequest. Unknown keys are rejected by the API.

    .EXAMPLE
        $token = New-EvoDeploymentToken -Name 'Acme rollout' -TenantId 'TENANT_GUID' -DirectoryId 'DIRECTORY_GUID'
        $token.deploymentToken

    .EXAMPLE
        New-EvoDeploymentToken -Name 'Acme JIT' -TenantId 'TENANT_GUID' -ExpireAt (Get-Date).AddDays(30) -Settings @{ enableJit = $true; authenticationMode = 'elevation' }
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$TenantId,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$DirectoryId,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [bool]$Active,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [datetime]$ExpireAt,

        [Parameter()]
        [hashtable]$Settings
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Deployment token '$Name'", 'Create')) {
            return
        }

        $body = @{
            name     = $Name
            tenantId = $TenantId
        }

        if ($DirectoryId) {
            $body['directoryId'] = $DirectoryId
        }

        if ($PSBoundParameters.ContainsKey('Active')) {
            $body['active'] = $Active
        }

        if ($PSBoundParameters.ContainsKey('ExpireAt')) {
            $body['expireAt'] = $ExpireAt.ToUniversalTime().ToString('o')
        }

        if ($Settings) {
            $body['settings'] = $Settings
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/deployment_tokens' -Body $body

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
