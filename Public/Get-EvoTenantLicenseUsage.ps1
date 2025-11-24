function Get-EvoTenantLicenseUsage {
    <#
    .SYNOPSIS
        Get license usage details for a specific tenant.

    .DESCRIPTION
        Calls the /v1/tenants/{id}/licenses/usage endpoint and returns
        license usage details for the specified tenant.

    .PARAMETER TenantId
        The ID of the tenant.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$TenantId
    )

    process {
        $path = "/v1/tenants/$TenantId/licenses/usage"
        $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($usage in $response.data) {
                if ($usage -is [pscustomobject]) {
                    $usage.PSObject.TypeNames.Insert(0, 'Evo.TenantLicenseUsage')
                }
                Write-Output $usage
            }
        }
        else {
            Write-Output $response
        }
    }
}
