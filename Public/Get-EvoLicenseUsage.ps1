function Get-EvoLicenseUsage {
    <#
    .SYNOPSIS
        Get license usage for all tenants in the current environment.

    .DESCRIPTION
        Calls the /v1/licenses/usage endpoint and returns license usage
        details per tenant.
    #>
    [CmdletBinding()]
    param()

    $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/licenses/usage'

    if ($null -ne $response -and $response.PSObject.Properties['data']) {
        foreach ($item in $response.data) {
            if ($item -is [pscustomobject]) {
                $item.PSObject.TypeNames.Insert(0, 'Evo.LicenseUsageSummary')
            }
            Write-Output $item
        }
    }
    else {
        Write-Output $response
    }
}
