function Remove-EvoRbacRoleAssignedGroup {
    <#
    .SYNOPSIS
        Unassign an RBAC v2 role from one or more groups.

    .DESCRIPTION
        Unassigns the role from the given groups via the
        /v1/rbac_roles/{id}/groups endpoint (DELETE). This is the role-side way
        to manage assignments; the group-side equivalent is
        Remove-EvoGroupRbacRole.

        Built-in (stock) roles are assignable even though they cannot be edited.

    .PARAMETER RbacRoleId
        ID (selector UUID) of the role.

    .PARAMETER GroupIdList
        One or more group IDs (selector UUIDs).

    .EXAMPLE
        Remove-EvoRbacRoleAssignedGroup -RbacRoleId $role.id -GroupIdList $ids

        Unassigns the role from the listed groups.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$RbacRoleId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('GroupIds')]
        [string[]]$GroupIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("RBAC role '$RbacRoleId'", 'Unassign groups')) {
            return
        }

        $body = @{
            groupIds = $GroupIdList
        }

        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path "/v1/rbac_roles/$RbacRoleId/groups" -Body $body
        Write-Output $response
    }
}
