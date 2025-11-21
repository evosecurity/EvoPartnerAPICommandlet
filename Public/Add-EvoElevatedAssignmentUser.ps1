function Add-EvoElevatedAssignmentUser {
    <#
    .SYNOPSIS
        Add users to an elevated assignment.

    .DESCRIPTION
        Adds one or more users as members of an elevated assignment via
        /v1/elevated_assignments/{id}/users.

    .PARAMETER ElevatedAssignmentId
        The ID of the elevated assignment.

    .PARAMETER UserIdList
        One or more user IDs to add to the elevated assignment.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ElevatedAssignmentId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$UserIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Elevated assignment $ElevatedAssignmentId", 'Add users')) {
            return
        }

        $body = @{ userIds = $UserIdList }
        $path = "/v1/elevated_assignments/$ElevatedAssignmentId/users"
        $response = Invoke-EvoApiRequest -Method 'POST' -Path $path -Body $body
        Write-Output $response
    }
}
