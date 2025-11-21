function Add-EvoGroupTenantAccess {
    <#
    .SYNOPSIS
        Grant a group access to one or more tenants.

    .DESCRIPTION
        Calls the /v1/groups/{id}/tenant_accesses POST endpoint to
        create tenant access records for the specified group.

    .PARAMETER GroupId
        The ID of the group.

    .PARAMETER TenantIdList
        One or more tenant IDs to grant access to.
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
        if (-not $PSCmdlet.ShouldProcess("Group $GroupId", 'Add tenant accesses')) {
            return
        }

        $body = @{
            tenantIds = $TenantIdList
        }

        $path = "/v1/groups/$GroupId/tenant_accesses"
        $response = Invoke-EvoApiRequest -Method 'POST' -Path $path -Body $body
        Write-Output $response
    }
}
