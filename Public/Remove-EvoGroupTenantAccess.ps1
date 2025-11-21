function Remove-EvoGroupTenantAccess {
    <#
    .SYNOPSIS
        Revoke a group's access to one or more tenants.

    .DESCRIPTION
        Calls the /v1/groups/{id}/tenant_accesses DELETE endpoint to
        delete tenant access records for the specified group.

    .PARAMETER GroupId
        The ID of the group.

    .PARAMETER TenantIdList
        One or more tenant IDs to revoke access from.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$GroupId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$TenantIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Group $GroupId", 'Remove tenant accesses')) {
            return
        }

        $body = @{
            tenantIds = $TenantIdList
        }

        $path = "/v1/groups/$GroupId/tenant_accesses"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path -Body $body
        Write-Output $response
    }
}
