function Remove-EvoUserTenantAccess {
    <#
    .SYNOPSIS
        Revoke a user's access to one or more tenants.

    .DESCRIPTION
        Calls the /v1/users/{id}/tenant_accesses DELETE endpoint to
        remove tenant access records for the specified user.

    .PARAMETER UserId
        The ID of the user.

    .PARAMETER TenantIdList
        One or more tenant IDs to remove access from.

    .EXAMPLE
        Remove-EvoUserTenantAccess -UserId '00000000-0000-0000-0000-000000000000' -TenantIdList 'tenant-guid-1'
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
        if (-not $PSCmdlet.ShouldProcess("User $UserId", 'Remove tenant accesses')) {
            return
        }

        $body = @{
            tenantIds = $TenantIdList
        }

        $path = "/v1/users/$UserId/tenant_accesses"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path -Body $body
        Write-Output $response
    }
}
