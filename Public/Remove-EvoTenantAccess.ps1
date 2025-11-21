function Remove-EvoTenantAccess {
    <#
    .SYNOPSIS
        Revoke tenant access from users and/or groups.

    .DESCRIPTION
        Calls the /v1/tenants/{id}/tenant_accesses DELETE endpoint to
        remove tenant access records.

    .PARAMETER TenantId
        The ID of the tenant.

    .PARAMETER UserIdList
        Optional list of user IDs to remove access from.

    .PARAMETER GroupIdList
        Optional list of group IDs to remove access from.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$TenantId,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]$UserIdList,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]$GroupIdList
    )

    process {
        if (-not $UserIdList -and -not $GroupIdList) {
            throw 'At least one of -UserIdList or -GroupIdList must be provided.'
        }

        if (-not $PSCmdlet.ShouldProcess("Tenant $TenantId", 'Remove tenant accesses')) {
            return
        }

        $body = @{}
        if ($UserIdList) {
            $body['userIds'] = $UserIdList
        }
        if ($GroupIdList) {
            $body['groupIds'] = $GroupIdList
        }

        $path = "/v1/tenants/$TenantId/tenant_accesses"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path -Body $body
        Write-Output $response
    }
}
