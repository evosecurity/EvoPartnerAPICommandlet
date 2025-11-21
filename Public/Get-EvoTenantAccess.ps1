function Get-EvoTenantAccess {
    <#
    .SYNOPSIS
        Get users and groups that have access to a tenant.

    .DESCRIPTION
        Retrieves tenant accesses via the /v1/tenants/{id}/tenant_accesses
        endpoint with optional paging and filtering.

    .PARAMETER TenantId
        The ID of the tenant.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .PARAMETER Query
        Optional free-text search across user and group fields.

    .PARAMETER Type
        Optional filter for access type: user or group.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$TenantId,

        [Parameter()]
        [int]$Page,

        [Parameter()]
        [int]$Limit,

        [Parameter()]
        [Alias('Q')]
        [string]$Query,

        [Parameter()]
        [ValidateSet('user','group')]
        [string]$Type
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

        if ($PSBoundParameters.ContainsKey('Query') -and $Query) {
            $queryParams['q'] = $Query
        }

        if ($PSBoundParameters.ContainsKey('Type') -and $Type) {
            $queryParams['type'] = $Type
        }

        $path = "/v1/tenants/$TenantId/tenant_accesses"
        $response = Invoke-EvoApiRequest -Method 'GET' -Path $path -Query $queryParams
        Write-Output $response
    }
}
