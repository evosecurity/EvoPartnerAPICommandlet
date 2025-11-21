function Remove-EvoGroupRoleGroup {
    <#
    .SYNOPSIS
        Remove role groups from a group.

    .DESCRIPTION
        Calls the /v1/groups/{id}/role_groups DELETE endpoint to remove
        one or more role groups from the specified group.

    .PARAMETER GroupId
        The ID of the group.

    .PARAMETER RoleGroupIdList
        One or more role group IDs to remove from the group.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$GroupId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$RoleGroupIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Group $GroupId", 'Remove role groups')) {
            return
        }

        $body = @{
            roleGroupIds = $RoleGroupIdList
        }

        $path = "/v1/groups/$GroupId/role_groups"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path -Body $body
        Write-Output $response
    }
}
