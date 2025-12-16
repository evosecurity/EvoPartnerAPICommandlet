function Get-EvoRoleGroup {
    <#
    .SYNOPSIS
        Get role groups for the current environment.

    .DESCRIPTION
        Retrieves role groups via the /v1/role_groups endpoint. Can retrieve
        a single role group by ID or list role groups with pagination.

    .PARAMETER Id
        Optional ID of a specific role group to retrieve.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .PARAMETER Query
        Optional search term applied to role group name and description.

    .EXAMPLE
        Get-EvoRoleGroup

        Retrieves all role groups.

    .EXAMPLE
        Get-EvoRoleGroup -Id 'role-group-id'

        Retrieves a specific role group.

    .EXAMPLE
        Get-EvoRoleGroup -Query 'Admin'

        Retrieves role groups matching 'Admin'.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'Single', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('RoleGroupId')]
        [string]$Id,

        [Parameter(ParameterSetName = 'List')]
        [Nullable[int]]$Page,

        [Parameter(ParameterSetName = 'List')]
        [Nullable[int]]$Limit,

        [Parameter(ParameterSetName = 'List')]
        [Alias('Q')]
        [string]$Query
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Single') {
            $path = "/v1/role_groups/$Id"
            $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

            if ($response.data) {
                $rg = $response.data

                if ($rg -is [pscustomobject]) {
                    $rg.PSObject.TypeNames.Insert(0, 'Evo.RoleGroup')
                }

                Write-Output $rg
            }
            else {
                Write-Output $response
            }
        }
        else {
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

            $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/role_groups' -Query $queryParams

            if ($response.data) {
                foreach ($rg in $response.data) {
                    if ($rg -is [pscustomobject]) {
                        $rg.PSObject.TypeNames.Insert(0, 'Evo.RoleGroup')
                    }
                    Write-Output $rg
                }
            }
            else {
                Write-Output $response
            }
        }
    }
}
