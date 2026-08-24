function Get-EvoRbacRoleAssignedUser {
    <#
    .SYNOPSIS
        Get the users assigned to an RBAC v2 role.

    .DESCRIPTION
        Retrieves the users currently assigned to a role via the
        /v1/rbac_roles/{id}/users endpoint. This is the role-side view of the
        assignment; the user-side view is Get-EvoUserRbacRole.

    .PARAMETER RbacRoleId
        ID (selector UUID) of the role.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .EXAMPLE
        Get-EvoRbacRoleAssignedUser -RbacRoleId $role.id

        Lists the users holding the role.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$RbacRoleId,

        [Parameter()]
        [Nullable[int]]$Page,

        [Parameter()]
        [Nullable[int]]$Limit
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

        $response = Invoke-EvoApiRequest -Method 'GET' -Path "/v1/rbac_roles/$RbacRoleId/users" -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($item in $response.data) {
                if ($item -is [pscustomobject]) {
                    $item.PSObject.TypeNames.Insert(0, 'Evo.User')
                }
                Write-Output $item
            }
        }
        else {
            Write-Output $response
        }
    }
}
