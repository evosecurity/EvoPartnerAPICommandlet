function Get-EvoGroup {
    <#
    .SYNOPSIS
        Get Evo groups in the current environment.

    .DESCRIPTION
        Retrieves one or more groups from the Evo Partner API. When
        called with -Id, returns a single group. When called without
        -Id, lists groups with optional filters and paging.

    .PARAMETER Id
        The ID of the group to retrieve.

    .PARAMETER Page
        Page number for paginated queries when listing groups.

    .PARAMETER Limit
        Maximum number of groups per page. Defaults to the module
        configuration's DefaultPageSize.

    .PARAMETER Query
        Optional free-text search applied to group name and description.

    .PARAMETER TenantIdList
        Filter groups by one or more tenant IDs.

    .EXAMPLE
        Get-EvoGroup

        Returns the first page of groups.

    .EXAMPLE
        Get-EvoGroup -Id '00000000-0000-0000-0000-000000000000'

        Returns the group with the specified ID.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('GroupId')]
        [string]$Id,

        [Parameter(ParameterSetName = 'List')]
        [int]$Page,

        [Parameter(ParameterSetName = 'List')]
        [int]$Limit,

        [Parameter(ParameterSetName = 'List')]
        [Alias('Q')]
        [string]$Query,

        [Parameter(ParameterSetName = 'List')]
        [string[]]$TenantIdList
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $path = "/v1/groups/$Id"
            $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                $group = $response.data
                if ($group -is [pscustomobject]) {
                    $group.PSObject.TypeNames.Insert(0, 'Evo.Group')
                }
                return $group
            }

            return $response
        }

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

        if ($TenantIdList) {
            $queryParams['tenantIds[]'] = $TenantIdList
        }

        $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/groups' -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($group in $response.data) {
                if ($group -is [pscustomobject]) {
                    $group.PSObject.TypeNames.Insert(0, 'Evo.Group')
                }
                Write-Output $group
            }
        }
        else {
            Write-Output $response
        }
    }
}
