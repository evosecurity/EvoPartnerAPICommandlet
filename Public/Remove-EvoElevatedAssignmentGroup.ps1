function Remove-EvoElevatedAssignmentGroup {
    <#
    .SYNOPSIS
        Remove groups from an elevated assignment.

    .DESCRIPTION
        Removes one or more groups from an elevated assignment via
        /v1/elevated_assignments/{id}/groups DELETE.

    .PARAMETER ElevatedAssignmentId
        The ID of the elevated assignment.

    .PARAMETER GroupIdList
        One or more group IDs to remove from the elevated assignment.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ElevatedAssignmentId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$GroupIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Elevated assignment $ElevatedAssignmentId", 'Remove groups')) {
            return
        }

        $body = @{ groupIds = $GroupIdList }
        $path = "/v1/elevated_assignments/$ElevatedAssignmentId/groups"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path -Body $body
        Write-Output $response
    }
}
