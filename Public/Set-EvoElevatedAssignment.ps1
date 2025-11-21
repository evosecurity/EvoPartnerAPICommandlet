function Set-EvoElevatedAssignment {
    <#
    .SYNOPSIS
        Update an elevated assignment.

    .DESCRIPTION
        Updates the name, description, or active status of an elevated
        assignment via /v1/elevated_assignments/{id}.

    .PARAMETER Id
        The ID of the elevated assignment to update.

    .PARAMETER Name
        New name.

    .PARAMETER Description
        New description.

    .PARAMETER Active
        Whether the assignment is active.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('ElevatedAssignmentId')]
        [string]$Id,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Description,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [bool]$Active
    )

    process {
        $body = @{}

        if ($PSBoundParameters.ContainsKey('Name')) {
            $body['name'] = $Name
        }
        if ($PSBoundParameters.ContainsKey('Description')) {
            $body['description'] = $Description
        }
        if ($PSBoundParameters.ContainsKey('Active')) {
            $body['active'] = $Active
        }

        if ($body.Count -eq 0) {
            Write-Verbose 'No updatable fields were provided.'
            return
        }

        if (-not $PSCmdlet.ShouldProcess("Elevated assignment $Id", 'Update')) {
            return
        }

        $path = "/v1/elevated_assignments/$Id"
        $response = Invoke-EvoApiRequest -Method 'PUT' -Path $path -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $assignment = $response.data
            if ($assignment -is [pscustomobject]) {
                $assignment.PSObject.TypeNames.Insert(0, 'Evo.ElevatedAssignment')
            }
            Write-Output $assignment
        }
        else {
            Write-Output $response
        }
    }
}
