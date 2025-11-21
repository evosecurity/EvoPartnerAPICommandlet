function Remove-EvoElevatedAssignment {
    <#
    .SYNOPSIS
        Delete an elevated assignment by ID.

    .DESCRIPTION
        Deletes an elevated assignment via the /v1/elevated_assignments/{id}
        endpoint.

    .PARAMETER Id
        The ID of the elevated assignment to delete.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('ElevatedAssignmentId')]
        [string]$Id
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Elevated assignment $Id", 'Delete')) {
            return
        }

        $path = "/v1/elevated_assignments/$Id"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path
        Write-Output $response
    }
}
