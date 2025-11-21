function Get-EvoElevatedAssignmentGroup {
    <#
    .SYNOPSIS
        Get groups in an elevated assignment.

    .DESCRIPTION
        Retrieves groups that are members of an elevated assignment via
        /v1/elevated_assignments/{id}/groups.

    .PARAMETER ElevatedAssignmentId
        The ID of the elevated assignment.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$ElevatedAssignmentId,

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

        $path = "/v1/elevated_assignments/$ElevatedAssignmentId/groups"
        $response = Invoke-EvoApiRequest -Method 'GET' -Path $path -Query $queryParams
        Write-Output $response
    }
}
