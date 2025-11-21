function Get-EvoElevatedAssignment {
    <#
    .SYNOPSIS
        Get elevated assignments in the current environment.

    .DESCRIPTION
        Retrieves elevated assignments via the /v1/elevated_assignments
        and /v1/elevated_assignments/{id} endpoints.

    .PARAMETER Id
        The ID of the elevated assignment to retrieve.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .PARAMETER Query
        Optional search term applied to name and description.

    .PARAMETER Active
        Optional filter for active status: 'true' or 'false'.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('ElevatedAssignmentId')]
        [string]$Id,

        [Parameter(ParameterSetName = 'List')]
        [int]$Page,

        [Parameter(ParameterSetName = 'List')]
        [int]$Limit,

        [Parameter(ParameterSetName = 'List')]
        [Alias('Q')]
        [string]$Query,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('true','false')]
        [string]$Active
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $path = "/v1/elevated_assignments/$Id"
            $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                $assignment = $response.data
                if ($assignment -is [pscustomobject]) {
                    $assignment.PSObject.TypeNames.Insert(0, 'Evo.ElevatedAssignment')
                }
                return $assignment
            }

            return $response
        }

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

        if ($PSBoundParameters.ContainsKey('Active') -and $Active) {
            $queryParams['active'] = $Active
        }

        $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/elevated_assignments' -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($assignment in $response.data) {
                if ($assignment -is [pscustomobject]) {
                    $assignment.PSObject.TypeNames.Insert(0, 'Evo.ElevatedAssignment')
                }
                Write-Output $assignment
            }
        }
        else {
            Write-Output $response
        }
    }
}
