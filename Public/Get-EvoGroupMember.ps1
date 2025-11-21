function Get-EvoGroupMember {
    <#
    .SYNOPSIS
        Get members of a specific group.

    .DESCRIPTION
        Retrieves group members via the /v1/groups/{id}/members
        endpoint.

    .PARAMETER GroupId
        The ID of the group.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .PARAMETER Query
        Optional search term applied to email, first name, or last name.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$GroupId,

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

        $path = "/v1/groups/$GroupId/members"
        $response = Invoke-EvoApiRequest -Method 'GET' -Path $path -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($member in $response.data) {
                if ($member -is [pscustomobject]) {
                    $member.PSObject.TypeNames.Insert(0, 'Evo.GroupMember')
                }
                Write-Output $member
            }
        }
        else {
            Write-Output $response
        }
    }
}
