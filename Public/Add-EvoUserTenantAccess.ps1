function Add-EvoUserTenantAccess {
    <#
    .SYNOPSIS
        Grant a user access to one or more tenants.

    .DESCRIPTION
        Calls the /v1/users/{id}/tenant_accesses POST endpoint to create
        tenant access records for an admin user. Returns the full API
        response including any failedItems.

    .PARAMETER UserId
        The ID of the user.

    .PARAMETER TenantIdList
        One or more tenant IDs to grant access to.

    .EXAMPLE
        Add-EvoUserTenantAccess -UserId '00000000-0000-0000-0000-000000000000' -TenantIdList 'tenant-guid-1','tenant-guid-2'
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$UserId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$TenantIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("User $UserId", 'Add tenant accesses')) {
            return
        }

        $body = @{
            tenantIds = $TenantIdList
        }

        $path = "/v1/users/$UserId/tenant_accesses"
        $response = Invoke-EvoApiRequest -Method 'POST' -Path $path -Body $body
        Write-Output $response
    }
}
