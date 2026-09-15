function Get-EvoPermission {
    <#
    .SYNOPSIS
        Get the RBAC v2 permission catalog as a flat list.

    .DESCRIPTION
        Retrieves permissions via the /v1/permissions endpoint. This is the
        RBAC v2 counterpart to the legacy Get-EvoRole cmdlet. Use
        Get-EvoPermissionCatalog for the nested category/group tree.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .PARAMETER Query
        Optional search term applied to permission display name and description.

    .PARAMETER Category
        Optional filter by category key.

    .PARAMETER Namespace
        Optional product namespace filter (admin_portal or mobile).

    .EXAMPLE
        Get-EvoPermission

        Retrieves the first page of permissions.

    .EXAMPLE
        Get-EvoPermission -Query 'billing' -Limit 100

        Searches the permission catalog for billing permissions.
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
        [string]$Category,

        [Parameter()]
        [ValidateSet('admin_portal','mobile')]
        [string]$Namespace
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

        if ($PSBoundParameters.ContainsKey('Category') -and $Category) {
            $queryParams['category'] = $Category
        }

        if ($PSBoundParameters.ContainsKey('Namespace') -and $Namespace) {
            $queryParams['namespace'] = $Namespace
        }

        $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/permissions' -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($permission in $response.data) {
                if ($permission -is [pscustomobject]) {
                    $permission.PSObject.TypeNames.Insert(0, 'Evo.Permission')
                }
                Write-Output $permission
            }
        }
        else {
            Write-Output $response
        }
    }
}
