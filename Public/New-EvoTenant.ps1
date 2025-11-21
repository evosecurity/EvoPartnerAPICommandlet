function New-EvoTenant {
    <#
    .SYNOPSIS
        Create a new tenant.

    .DESCRIPTION
        Creates a new tenant in the current environment via the
        /v1/tenants endpoint.

    .PARAMETER Name
        The name of the tenant.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Name
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Tenant '$Name'", 'Create')) {
            return
        }

        $body = @{ name = $Name }
        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/tenants' -Body $body

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
