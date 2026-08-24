function Get-EvoUserRbacRole {
    <#
    .SYNOPSIS
        Get the RBAC v2 roles assigned to a user.

    .DESCRIPTION
        Retrieves the roles currently assigned to a user via the
        /v1/users/{id}/rbac_roles endpoint. This is the RBAC v2 counterpart to
        the legacy Get-EvoUserRoleGroup cmdlet; note the two use different id
        spaces, so ids are not interchangeable between them.

    .PARAMETER UserId
        ID (selector UUID) of the user.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .EXAMPLE
        Get-EvoUserRbacRole -UserId $user.id

        Lists the roles held by the user.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$UserId,

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

        $response = Invoke-EvoApiRequest -Method 'GET' -Path "/v1/users/$UserId/rbac_roles" -Query $queryParams

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
