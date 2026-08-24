function Get-EvoGroupRbacRole {
    <#
    .SYNOPSIS
        Get the RBAC v2 roles assigned to a group.

    .DESCRIPTION
        Retrieves the roles currently assigned to a group via the
        /v1/groups/{id}/rbac_roles endpoint. This is the RBAC v2 counterpart to
        the legacy Get-EvoGroupRoleGroup cmdlet; note the two use different id
        spaces, so ids are not interchangeable between them.

    .PARAMETER GroupId
        ID (selector UUID) of the group.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .EXAMPLE
        Get-EvoGroupRbacRole -GroupId $group.id

        Lists the roles held by the group.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$GroupId,

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

        $response = Invoke-EvoApiRequest -Method 'GET' -Path "/v1/groups/$GroupId/rbac_roles" -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($role in $response.data) {
                if ($role -is [pscustomobject]) {
                    $role.PSObject.TypeNames.Insert(0, 'Evo.RbacRole')
                }
                Write-Output $role
            }
        }
        else {
            Write-Output $response
        }
    }
}
