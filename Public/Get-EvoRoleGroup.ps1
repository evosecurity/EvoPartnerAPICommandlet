function Get-EvoRoleGroup {
    <#
    .SYNOPSIS
        Get role groups for the current environment.

    .DESCRIPTION
        Retrieves role groups via the /v1/role_groups endpoint.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .PARAMETER Query
        Optional search term applied to role group name and description.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$Page,

        [Parameter()]
        [int]$Limit,

        [Parameter()]
        [Alias('Q')]
        [string]$Query
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

        $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/role_groups' -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
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
