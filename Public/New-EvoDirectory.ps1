function New-EvoDirectory {
    <#
    .SYNOPSIS
        Create a new Cloud Directory.

    .DESCRIPTION
        Creates a new Cloud Directory via the /v1/directories endpoint.

    .PARAMETER Name
        The name of the directory.

    .PARAMETER TenantId
        The tenant ID the directory belongs to.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$TenantId
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Directory '$Name'", 'Create')) {
            return
        }

        $body = @{ name = $Name; tenantId = $TenantId }
        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/directories' -Body $body

        if ($null -ne $response) {
            if ($response -is [pscustomobject]) {
                $response.PSObject.TypeNames.Insert(0, 'Evo.Directory')
            }
            Write-Output $response
        }
    }
}
