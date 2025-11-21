function Get-EvoTenant {
    <#
    .SYNOPSIS
        Get Evo tenants in the current environment.

    .DESCRIPTION
        Retrieves one or more tenants from the Evo Partner API. When
        called with -Id, returns a single tenant. When called without
        -Id, lists tenants with optional filters and paging. Use -All to
        automatically iterate through all pages.

    .PARAMETER Id
        The ID of the tenant to retrieve.

    .PARAMETER Page
        Page number for paginated queries when listing tenants.

    .PARAMETER Limit
        Maximum number of tenants per page. Defaults to the module
        configuration's DefaultPageSize.

    .PARAMETER Query
        Optional free-text search applied to tenant name or display
        name.

    .PARAMETER All
        When specified, automatically pages through all available result
        pages and streams tenants to the pipeline.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('TenantId')]
        [string]$Id,

        [Parameter(ParameterSetName = 'List')]
        [int]$Page,

        [Parameter(ParameterSetName = 'List')]
        [int]$Limit,

        [Parameter(ParameterSetName = 'List')]
        [Alias('Q')]
        [string]$Query,

        [Parameter(ParameterSetName = 'List')]
        [switch]$All
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $path = "/v1/tenants/$Id"
            $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                $tenant = $response.data
                if ($tenant -is [pscustomobject]) {
                    $tenant.PSObject.TypeNames.Insert(0, 'Evo.Tenant')
                }
                return $tenant
            }

            return $response
        }

        $currentPage = if ($PSBoundParameters.ContainsKey('Page')) { $Page } else { 1 }
        $pageSize = if ($PSBoundParameters.ContainsKey('Limit')) { $Limit } else { $script:EvoPartnerApiConfig.DefaultPageSize }

        if ($pageSize -le 0) {
            throw 'Limit must be greater than zero.'
        }

        do {
            $queryParams = @{
                page  = $currentPage
                limit = $pageSize
            }

            if ($PSBoundParameters.ContainsKey('Query') -and $Query) {
                $queryParams['q'] = $Query
            }

            $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/tenants' -Query $queryParams

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                foreach ($tenant in $response.data) {
                    if ($tenant -is [pscustomobject]) {
                        $tenant.PSObject.TypeNames.Insert(0, 'Evo.Tenant')
                    }
                    Write-Output $tenant
                }
            }
            else {
                Write-Output $response
            }

            $hasMore = $false
            if ($All.IsPresent -and $response -and $response.PSObject.Properties['pagination']) {
                $pagination = $response.pagination
                if ($pagination -and $pagination.page -lt $pagination.totalPages) {
                    $currentPage = [int]$pagination.page + 1
                    $hasMore = $true
                }
            }
        }
        while ($hasMore)
    }
}
