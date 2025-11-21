function Add-EvoElevatedAssignmentGroup {
    <#
    .SYNOPSIS
        Add groups to an elevated assignment.

    .DESCRIPTION
        Adds one or more groups as members of an elevated assignment via
        /v1/elevated_assignments/{id}/groups.

    .PARAMETER ElevatedAssignmentId
        The ID of the elevated assignment.

    .PARAMETER GroupIdList
        One or more group IDs to add to the elevated assignment.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ElevatedAssignmentId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$GroupIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Elevated assignment $ElevatedAssignmentId", 'Add groups')) {
            return
        }

        $body = @{ groupIds = $GroupIdList }
        $path = "/v1/elevated_assignments/$ElevatedAssignmentId/groups"
        $response = Invoke-EvoApiRequest -Method 'POST' -Path $path -Body $body
        Write-Output $response
    }
}
