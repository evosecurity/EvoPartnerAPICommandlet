function Get-EvoElevationRequest {
    <#
    .SYNOPSIS
        Get End-User Elevation (EUE) requests.

    .DESCRIPTION
        Retrieves EUE requests from the Evo Partner API. With -Id (and -TenantId) it
        returns a single request; otherwise it lists requests with optional filters,
        newest first. Requests still being analyzed are not listed. A request waiting
        for a human decision has state 'pending'.

        Requires an API key with the canManageElevationRequests scope.

    .PARAMETER Id
        The ID of the elevation request to retrieve (for example er_01HAYTFG4CRA6FVCFMJQYCP2SM).

    .PARAMETER TenantId
        The tenant the request belongs to. Required with -Id; optional filter when listing.

    .PARAMETER State
        Filter by one or more states: init, pending, approved, denied, cancelled.

    .PARAMETER Kind
        Filter by one or more OS kinds: windows, macos.

    .PARAMETER SortDirection
        Sort by creation time: desc (default) or asc.

    .PARAMETER Page
        Page number when listing.

    .PARAMETER Limit
        Maximum number of requests per page. Defaults to the module configuration's DefaultPageSize.

    .PARAMETER All
        Page through all results and stream them to the pipeline.

    .EXAMPLE
        Get-EvoElevationRequest -State pending -All

        Returns every elevation request waiting for a decision.

    .EXAMPLE
        Get-EvoElevationRequest -Id 'er_01HAYTFG4CRA6FVCFMJQYCP2SM' -TenantId '00000000-0000-0000-0000-000000000000'

        Returns one request with its current state and resolution.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('ElevationRequestId')]
        [string]$Id,

        [Parameter(ParameterSetName = 'ById', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'List')]
        [string]$TenantId,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('init', 'pending', 'approved', 'denied', 'cancelled')]
        [string[]]$State,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('windows', 'macos')]
        [string[]]$Kind,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('asc', 'desc')]
        [string]$SortDirection,

        [Parameter(ParameterSetName = 'List')]
        [Nullable[int]]$Page,

        [Parameter(ParameterSetName = 'List')]
        [Nullable[int]]$Limit,

        [Parameter(ParameterSetName = 'List')]
        [switch]$All
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $response = Invoke-EvoApiRequest -Method 'GET' -Path "/v1/elevation_requests/$Id" -Query @{ tenantId = $TenantId }

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                $request = $response.data
                if ($request -is [pscustomobject]) {
                    $request.PSObject.TypeNames.Insert(0, 'Evo.ElevationRequest')
                }
                return $request
            }

            return $response
        }

        $currentPage = if ($Page) { $Page } else { 1 }
        $pageSize = if ($PSBoundParameters.ContainsKey('Limit') -and $null -ne $Limit) { $Limit } else { $script:EvoPartnerApiConfig.DefaultPageSize }

        if ($pageSize -le 0) {
            throw 'Limit must be greater than zero.'
        }

        do {
            $queryParams = @{
                page  = $currentPage
                limit = $pageSize
            }

            if ($TenantId) { $queryParams['tenantId'] = $TenantId }
            if ($State) { $queryParams['state'] = ($State -join ',') }
            if ($Kind) { $queryParams['kind'] = ($Kind -join ',') }
            if ($SortDirection) { $queryParams['sortDirection'] = $SortDirection }

            $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/elevation_requests' -Query $queryParams

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                foreach ($request in $response.data) {
                    if ($request -is [pscustomobject]) {
                        $request.PSObject.TypeNames.Insert(0, 'Evo.ElevationRequest')
                    }
                    Write-Output $request
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
