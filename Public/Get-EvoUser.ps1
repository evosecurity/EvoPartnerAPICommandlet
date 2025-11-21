function Get-EvoUser {
    <#
    .SYNOPSIS
        Get Evo users in the current environment.

    .DESCRIPTION
        Retrieves one or more users from the Evo Partner API. When called
        with -Id, it returns a single user. When called without -Id, it
        lists users with optional filters and paging or returns all users
        when -All is specified.

    .PARAMETER Id
        The ID of the user to retrieve.

    .PARAMETER Page
        Page number for paginated queries when listing users.

    .PARAMETER Limit
        Maximum number of users per page. Defaults to the module
        configuration's DefaultPageSize.

    .PARAMETER Query
        Optional free-text search applied to email, first name, or last
        name. Maps to the q query parameter.

    .PARAMETER TenantId
        Filter users by a single tenant ID.

    .PARAMETER TenantIdList
        Filter users by one or more tenant IDs.

    .PARAMETER DirectoryId
        Filter users by a single directory ID.

    .PARAMETER DirectoryIdList
        Filter users by one or more directory IDs.

    .PARAMETER IsAdmin
        Filter users by admin status.

    .PARAMETER All
        When specified, automatically pages through all available
        result pages and streams users to the pipeline.

    .EXAMPLE
        Get-EvoUser -All

        Returns all active users in the current environment.

    .EXAMPLE
        Get-EvoUser -Id '00000000-0000-0000-0000-000000000000'

        Returns the user with the specified ID.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('UserId')]
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
        [string]$DirectoryId,

        [Parameter(ParameterSetName = 'List')]
        [string[]]$DirectoryIdList,

        [Parameter(ParameterSetName = 'List')]
        [bool]$IsAdmin,

        [Parameter(ParameterSetName = 'List')]
        [switch]$All
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $path = "/v1/users/$Id"
            $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                $user = $response.data
                if ($null -ne $user) {
                    if ($user -is [pscustomobject]) {
                        $user.PSObject.TypeNames.Insert(0, 'Evo.User')
                    }
                    return $user
                }
            }

            return $response
        }

        # List users
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

            $directoryIds = @()
            if ($PSBoundParameters.ContainsKey('DirectoryId') -and $DirectoryId) {
                $directoryIds += $DirectoryId
            }
            if ($PSBoundParameters.ContainsKey('DirectoryIdList') -and $DirectoryIdList) {
                $directoryIds += $DirectoryIdList
            }
            if ($directoryIds.Count -gt 0) {
                $queryParams['directoryIds[]'] = $directoryIds
            }

            if ($PSBoundParameters.ContainsKey('IsAdmin')) {
                $queryParams['isAdmin'] = if ($IsAdmin) { 'true' } else { 'false' }
            }

            $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/users' -Query $queryParams

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                foreach ($user in $response.data) {
                    if ($user -is [pscustomobject]) {
                        $user.PSObject.TypeNames.Insert(0, 'Evo.User')
                    }
                    Write-Output $user
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
