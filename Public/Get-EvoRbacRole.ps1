function Get-EvoRbacRole {
    <#
    .SYNOPSIS
        Get RBAC v2 roles for the current environment.

    .DESCRIPTION
        Retrieves roles via the /v1/rbac_roles endpoint. Can retrieve a single
        role by ID or list roles with pagination.

        RBAC v2 endpoints require the rbac_v2_enabled feature flag on the
        environment; without it the API responds 409 and the legacy
        Get-EvoRoleGroup cmdlet should be used instead.

    .PARAMETER Id
        Optional ID of a specific role to retrieve. This is the role selector
        (UUID) and is a different id space from legacy role group ids.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .PARAMETER Namespace
        Optional product namespace filter (admin_portal or mobile).

    .EXAMPLE
        Get-EvoRbacRole

        Retrieves all RBAC roles.

    .EXAMPLE
        Get-EvoRbacRole -Id 'e1e463a3-4cb9-43f1-8f62-70c214af15d1'

        Retrieves a specific role, including its grants.

    .EXAMPLE
        Get-EvoRbacRole -Namespace 'admin_portal'

        Retrieves roles in the admin portal namespace.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'Single', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('RbacRoleId')]
        [string]$Id,

        [Parameter(ParameterSetName = 'List')]
        [Nullable[int]]$Page,

        [Parameter(ParameterSetName = 'List')]
        [Nullable[int]]$Limit,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('admin_portal','mobile')]
        [string]$Namespace
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Single') {
            $response = Invoke-EvoApiRequest -Method 'GET' -Path "/v1/rbac_roles/$Id"

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                $role = $response.data

                if ($role -is [pscustomobject]) {
                    $role.PSObject.TypeNames.Insert(0, 'Evo.RbacRole')
                }

                Write-Output $role
            }
            else {
                Write-Output $response
            }
        }
        else {
            $currentPage = if ($PSBoundParameters.ContainsKey('Page')) { $Page } else { 1 }
            $pageSize = if ($PSBoundParameters.ContainsKey('Limit')) { $Limit } else { $script:EvoPartnerApiConfig.DefaultPageSize }

            if ($pageSize -le 0) {
                throw 'Limit must be greater than zero.'
            }

            $queryParams = @{
                page  = $currentPage
                limit = $pageSize
            }

            if ($PSBoundParameters.ContainsKey('Namespace') -and $Namespace) {
                $queryParams['namespace'] = $Namespace
            }

            $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/rbac_roles' -Query $queryParams

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
}
