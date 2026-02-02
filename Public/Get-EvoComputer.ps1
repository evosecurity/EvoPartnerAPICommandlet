function Get-EvoComputer {
    <#
    .SYNOPSIS
        Get computers (endpoints) in the current environment.

    .DESCRIPTION
        Retrieves one or more computers from the Evo Partner API. When called
        with -Id, it returns a single computer. When called without -Id, it
        lists computers with optional filters and paging or returns all computers
        when -All is specified.

    .PARAMETER Id
        The ID of the computer to retrieve.

    .PARAMETER Page
        Page number for paginated queries when listing computers.

    .PARAMETER Limit
        Maximum number of computers per page. Defaults to the module
        configuration's DefaultPageSize.

    .PARAMETER Query
        Optional free-text search applied to computer name. Maps to the q query parameter.

    .PARAMETER TenantId
        Filter computers by a single tenant ID.

    .PARAMETER TenantIdList
        Filter computers by one or more tenant IDs.

    .PARAMETER Os
        Filter computers by operating system: 'windows' or 'macos'.

    .PARAMETER All
        When specified, automatically pages through all available
        result pages and streams computers to the pipeline.

    .EXAMPLE
        Get-EvoComputer -All

        Returns all computers in the current environment.

    .EXAMPLE
        Get-EvoComputer -Id '00000000-0000-0000-0000-000000000000'

        Returns the computer with the specified ID.

    .EXAMPLE
        Get-EvoComputer -Os windows -All

        Returns all Windows computers.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('ComputerId')]
        [string]$Id,

        [Parameter(ParameterSetName = 'List')]
        [int]$Page,

        [Parameter(ParameterSetName = 'List')]
        [int]$Limit,

        [Parameter(ParameterSetName = 'List')]
        [Alias('Q')]
        [string]$Query,

        [Parameter(ParameterSetName = 'List')]
        [string]$TenantId,

        [Parameter(ParameterSetName = 'List')]
        [string[]]$TenantIdList,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('windows', 'macos')]
        [string]$Os,

        [Parameter(ParameterSetName = 'List')]
        [switch]$All
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $path = "/v1/computers/$Id"
            $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                $computer = $response.data
                if ($null -ne $computer) {
                    if ($computer -is [pscustomobject]) {
                        $computer.PSObject.TypeNames.Insert(0, 'Evo.Computer')
                    }
                    return $computer
                }
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

            $tenantIds = @()
            if ($PSBoundParameters.ContainsKey('TenantId') -and $TenantId) {
                $tenantIds += $TenantId
            }
            if ($PSBoundParameters.ContainsKey('TenantIdList') -and $TenantIdList) {
                $tenantIds += $TenantIdList
            }
            if ($tenantIds.Count -gt 0) {
                $queryParams['tenantIds[]'] = $tenantIds
            }

            if ($PSBoundParameters.ContainsKey('Os') -and $Os) {
                $queryParams['os'] = $Os
            }

            $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/computers' -Query $queryParams

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                foreach ($computer in $response.data) {
                    if ($computer -is [pscustomobject]) {
                        $computer.PSObject.TypeNames.Insert(0, 'Evo.Computer')
                    }
                    Write-Output $computer
                }
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
