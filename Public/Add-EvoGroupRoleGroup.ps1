function Add-EvoGroupRoleGroup {
    <#
    .SYNOPSIS
        Add role groups to a group.

    .DESCRIPTION
        Calls the /v1/groups/{id}/role_groups POST endpoint to add one
        or more role groups to the specified group.

    .PARAMETER GroupId
        The ID of the group.

    .PARAMETER RoleGroupIdList
        One or more role group IDs to add to the group.
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
        if (-not $PSCmdlet.ShouldProcess("Group $GroupId", 'Add role groups')) {
            return
        }

        $body = @{
            roleGroupIds = $RoleGroupIdList
        }

        $path = "/v1/groups/$GroupId/role_groups"
        $response = Invoke-EvoApiRequest -Method 'POST' -Path $path -Body $body
        Write-Output $response
    }
}
