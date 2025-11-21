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
    Write-Output $response
}
