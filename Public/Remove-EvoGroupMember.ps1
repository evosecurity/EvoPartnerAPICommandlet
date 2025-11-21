function Remove-EvoGroupMember {
    <#
    .SYNOPSIS
        Remove members from a group.

    .DESCRIPTION
        Removes multiple users from a group via the /v1/groups/{id}/members
        DELETE endpoint.

    .PARAMETER GroupId
        The ID of the group.

    .PARAMETER UserIdList
        One or more user IDs to remove from the group.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$GroupId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$UserIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Group $GroupId", 'Remove members')) {
            return
        }

        $body = @{
            userIds = $UserIdList
        }

        $path = "/v1/groups/$GroupId/members"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path -Body $body
        Write-Output $response
    }
}
