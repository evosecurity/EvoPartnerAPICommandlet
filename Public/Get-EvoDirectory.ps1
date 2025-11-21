function Get-EvoDirectory {
    <#
    .SYNOPSIS
        Get Cloud Directories for the current environment.

    .DESCRIPTION
        Retrieves Cloud Directories via the /v1/directories endpoint.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .PARAMETER Query
        Optional search term applied to directory name.

    .PARAMETER TenantIdList
        Optional list of tenant IDs to filter directories by.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$Page,

        [Parameter()]
        [int]$Limit,

        [Parameter()]
        [Alias('Q')]
        [string]$Query,

        [Parameter()]
        [string[]]$TenantIdList
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

        if ($TenantIdList) {
            $queryParams['tenantIds[]'] = $TenantIdList
        }

        $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/directories' -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($dir in $response.data) {
                if ($dir -is [pscustomobject]) {
                    $dir.PSObject.TypeNames.Insert(0, 'Evo.Directory')
                }
                Write-Output $dir
            }
        }
        else {
            Write-Output $response
        }
    }
}
