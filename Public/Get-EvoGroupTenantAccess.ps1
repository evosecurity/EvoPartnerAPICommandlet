function Get-EvoGroupTenantAccess {
    <#
    .SYNOPSIS
        Get tenant accesses for a specific group.

    .DESCRIPTION
        Retrieves tenant access records for the specified group via the
        /v1/groups/{id}/tenant_accesses endpoint.

    .PARAMETER GroupId
        The ID of the group.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$GroupId,

        [Parameter()]
        [int]$Page,

        [Parameter()]
        [int]$Limit
    )

    process {
        $currentPage = if ($PSBoundParameters.ContainsKey('Page')) { $Page } else { 1 }
        $pageSize = if ($PSBoundParameters.ContainsKey('Limit')) { $Limit } else { $script:EvoPartnerApiConfig.DefaultPageSize }

        if ($pageSize -le 0) {
            throw 'Limit must be greater than zero.'
        }

        $queryParams = @{
            page  = $currentPage
            limit = $pageSize
        }

        $path = "/v1/groups/$GroupId/tenant_accesses"
        $response = Invoke-EvoApiRequest -Method 'GET' -Path $path -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($item in $response.data) {
                if ($item -is [pscustomobject]) {
                    $item.PSObject.TypeNames.Insert(0, 'Evo.TenantAccess')
                }
                Write-Output $item
            }
        }
        else {
            Write-Output $response
        }
    }
}
