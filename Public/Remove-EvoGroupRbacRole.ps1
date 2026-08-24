function Remove-EvoGroupRbacRole {
    <#
    .SYNOPSIS
        Unassign RBAC v2 roles from a group.

    .DESCRIPTION
        Unassigns the given roles from a group via the
        /v1/groups/{id}/rbac_roles endpoint (DELETE). This is the RBAC v2
        counterpart to the legacy Remove-EvoGroupRoleGroup cmdlet.

    .PARAMETER GroupId
        ID (selector UUID) of the group.

    .PARAMETER RbacRoleIdList
        One or more role IDs (selector UUIDs).

    .EXAMPLE
        Remove-EvoGroupRbacRole -GroupId $group.id -RbacRoleIdList $role.id

        Unassigns a single role from the group.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$GroupId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('RbacRoleIds')]
        [string[]]$RbacRoleIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Group '$GroupId'", 'Unassign RBAC roles')) {
            return
        }

        $body = @{
            roleIds = $RbacRoleIdList
        }

        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path "/v1/groups/$GroupId/rbac_roles" -Body $body
        Write-Output $response
    }
}
