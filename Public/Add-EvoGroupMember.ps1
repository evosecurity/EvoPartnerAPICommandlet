function Add-EvoGroupMember {
    <#
    .SYNOPSIS
        Add members to a group.

    .DESCRIPTION
        Adds multiple users to a group via the /v1/groups/{id}/members
        POST endpoint.

    .PARAMETER GroupId
        The ID of the group.

    .PARAMETER UserIdList
        One or more user IDs to add to the group.
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
        if (-not $PSCmdlet.ShouldProcess("Group $GroupId", 'Add members')) {
            return
        }

        $body = @{
            userIds = $UserIdList
        }

        $path = "/v1/groups/$GroupId/members"
        $response = Invoke-EvoApiRequest -Method 'POST' -Path $path -Body $body
        Write-Output $response
    }
}
