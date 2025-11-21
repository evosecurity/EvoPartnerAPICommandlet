function Get-EvoUserTenantAccess {
    <#
    .SYNOPSIS
        Get tenant accesses for a specific Evo user.

    .DESCRIPTION
        Retrieves tenant access records for the specified user via the
        /v1/users/{id}/tenant_accesses endpoint. Supports basic paging
        with -Page and -Limit.

    .PARAMETER UserId
        The ID of the user whose tenant accesses should be retrieved.

    .PARAMETER Page
        Page number for the results. Defaults to 1.

    .PARAMETER Limit
        Number of items per page. Defaults to the module's
        DefaultPageSize configuration.

    .EXAMPLE
        Get-EvoUserTenantAccess -UserId '00000000-0000-0000-0000-000000000000'

        Returns the first page of tenant accesses for the specified user.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$UserId,

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

        $path = "/v1/users/$UserId/tenant_accesses"
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
