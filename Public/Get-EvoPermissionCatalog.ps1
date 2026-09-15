function Get-EvoPermissionCatalog {
    <#
    .SYNOPSIS
        Get the RBAC v2 permission catalog as a category tree.

    .DESCRIPTION
        Retrieves the nested catalog via the /v1/permissions/catalog endpoint:
        categories, their permission groups, and the permissions under each.
        This is the only way to discover the category and permission group keys
        accepted by New-EvoRbacRole and Set-EvoRbacRole.

        The response is not paginated.

    .PARAMETER Namespace
        Optional product namespace filter (admin_portal or mobile).

    .EXAMPLE
        Get-EvoPermissionCatalog

        Retrieves the full category tree.

    .EXAMPLE
        Get-EvoPermissionCatalog | Select-Object -ExpandProperty id

        Lists the category keys usable with -CategoryKeyList.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('admin_portal','mobile')]
        [string]$Namespace
    )

    process {
        $queryParams = @{}

        if ($PSBoundParameters.ContainsKey('Namespace') -and $Namespace) {
            $queryParams['namespace'] = $Namespace
        }

        $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/permissions/catalog' -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($category in $response.data) {
                if ($category -is [pscustomobject]) {
                    $category.PSObject.TypeNames.Insert(0, 'Evo.PermissionCategory')
                }
                Write-Output $category
            }
        }
        else {
            Write-Output $response
        }
    }
}
