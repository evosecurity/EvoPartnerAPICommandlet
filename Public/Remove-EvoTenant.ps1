function Remove-EvoTenant {
    <#
    .SYNOPSIS
        Delete a tenant by ID.

    .DESCRIPTION
        Deletes a tenant via the /v1/tenants/{id} endpoint.

    .PARAMETER Id
        The ID of the tenant to delete.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('TenantId')]
        [string]$Id
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Tenant $Id", 'Delete')) {
            return
        }

        $path = "/v1/tenants/$Id"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path
        Write-Output $response
    }
}
