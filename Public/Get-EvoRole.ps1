function Get-EvoRole {
    <#
    .SYNOPSIS
        Get roles for the current environment.

    .DESCRIPTION
        Retrieves roles via the /v1/roles endpoint. Only public roles are
        returned.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .PARAMETER Query
        Optional search term applied to role display name.

    .PARAMETER Category
        Optional filter by role category.

    .EXAMPLE
        Get-EvoRole

        Retrieves all available roles.

    .EXAMPLE
        Get-EvoRole -Query 'Admin' -Category 'Portal'

        Retrieves roles matching 'Admin' in the 'Portal' category.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [Nullable[int]]$Page,

        [Parameter()]
        [Nullable[int]]$Limit,

        [Parameter()]
        [Alias('Q')]
        [string]$Query,

        [Parameter()]
        [string]$Category
    )

    process {
        $currentPage = if ($Page -ne $null) { $Page } else { 1 }
        $pageSize = if ($Limit -ne $null) { $Limit } else { $script:EvoPartnerApiConfig.DefaultPageSize }

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

        if ($PSBoundParameters.ContainsKey('Category') -and $Category) {
            $queryParams['category'] = $Category
        }

        $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/roles' -Query $queryParams

        if ($response.data) {
            foreach ($role in $response.data) {
                if ($role -is [pscustomobject]) {
                    $role.PSObject.TypeNames.Insert(0, 'Evo.Role')
                }
                Write-Output $role
            }
        }
        else {
            Write-Output $response
        }
    }
}
