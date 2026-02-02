function Get-EvoDirectoryUser {
    <#
    .SYNOPSIS
        Get users in a specific directory.

    .DESCRIPTION
        Retrieves users for a directory via the /v1/directories/{id}/users endpoint.

    .PARAMETER DirectoryId
        The ID of the directory to retrieve users from.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .PARAMETER Query
        Optional search term applied to email, first name, or last name.

    .PARAMETER Type
        Optional filter for user type: manual or synced.

    .PARAMETER All
        When specified, automatically pages through all available
        result pages and streams users to the pipeline.

    .EXAMPLE
        Get-EvoDirectoryUser -DirectoryId 'directory-id' -All

        Returns all users in the specified directory.

    .EXAMPLE
        Get-EvoDirectoryUser -DirectoryId 'directory-id' -Type synced

        Returns only synced users in the directory.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$DirectoryId,

        [Parameter()]
        [int]$Page,

        [Parameter()]
        [int]$Limit,

        [Parameter()]
        [Alias('Q')]
        [string]$Query,

        [Parameter()]
        [ValidateSet('manual', 'synced')]
        [string]$Type,

        [Parameter()]
        [switch]$All
    )

    process {
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

            if ($PSBoundParameters.ContainsKey('Type') -and $Type) {
                $queryParams['type'] = $Type
            }

            $path = "/v1/directories/$DirectoryId/users"
            $response = Invoke-EvoApiRequest -Method 'GET' -Path $path -Query $queryParams

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                foreach ($user in $response.data) {
                    if ($user -is [pscustomobject]) {
                        $user.PSObject.TypeNames.Insert(0, 'Evo.DirectoryUser')
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
