function Get-EvoGroupRoleGroup {
    <#
    .SYNOPSIS
        Get role groups assigned to a specific group.

    .DESCRIPTION
        Retrieves role group assignments for the specified group via the
        /v1/groups/{id}/role_groups endpoint.

    .PARAMETER GroupId
        The ID of the group.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$GroupId,

        [Parameter()]
        [int]$Page,

        [Parameter()]
        [int]$Limit
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

        $path = "/v1/groups/$GroupId/role_groups"
        $response = Invoke-EvoApiRequest -Method 'GET' -Path $path -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($item in $response.data) {
                if ($item -is [pscustomobject]) {
                    $item.PSObject.TypeNames.Insert(0, 'Evo.RoleGroup')
                }
                Write-Output $item
            }
        }
        else {
            Write-Output $response
        }
    }
}
