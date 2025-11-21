function Remove-EvoElevatedAssignmentUser {
    <#
    .SYNOPSIS
        Remove users from an elevated assignment.

    .DESCRIPTION
        Removes one or more users from an elevated assignment via
        /v1/elevated_assignments/{id}/users DELETE.

    .PARAMETER ElevatedAssignmentId
        The ID of the elevated assignment.

    .PARAMETER UserIdList
        One or more user IDs to remove from the elevated assignment.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ElevatedAssignmentId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$UserIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Elevated assignment $ElevatedAssignmentId", 'Remove users')) {
            return
        }

        $body = @{ userIds = $UserIdList }
        $path = "/v1/elevated_assignments/$ElevatedAssignmentId/users"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path -Body $body
        Write-Output $response
    }
}
