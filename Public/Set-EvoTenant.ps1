function Set-EvoTenant {
    <#
    .SYNOPSIS
        Update an existing tenant's display name.

    .DESCRIPTION
        Updates a tenant via the /v1/tenants/{id} endpoint. Only the
        displayName field is updatable.

    .PARAMETER Id
        The ID of the tenant to update.

    .PARAMETER DisplayName
        New display name for the tenant.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('TenantId')]
        [string]$Id,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$DisplayName
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Tenant $Id", 'Update')) {
            return
        }

        $body = @{ displayName = $DisplayName }
        $path = "/v1/tenants/$Id"
        $response = Invoke-EvoApiRequest -Method 'PUT' -Path $path -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $tenant = $response.data
            if ($tenant -is [pscustomobject]) {
                $tenant.PSObject.TypeNames.Insert(0, 'Evo.Tenant')
            }
            Write-Output $tenant
        }
        else {
            Write-Output $response
        }
    }
}
