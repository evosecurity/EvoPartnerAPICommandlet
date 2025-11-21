function New-EvoElevatedAssignment {
    <#
    .SYNOPSIS
        Create a new elevated assignment.

    .DESCRIPTION
        Creates a new elevated assignment via the /v1/elevated_assignments
        endpoint.

    .PARAMETER Name
        Human-friendly name for the elevated assignment.

    .PARAMETER Description
        Optional description.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Description
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Elevated assignment '$Name'", 'Create')) {
            return
        }

        $body = @{ name = $Name }
        if ($PSBoundParameters.ContainsKey('Description') -and $Description) {
            $body['description'] = $Description
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/elevated_assignments' -Body $body

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
