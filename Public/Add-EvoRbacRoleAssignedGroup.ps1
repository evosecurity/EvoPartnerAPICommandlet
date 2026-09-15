function Add-EvoRbacRoleAssignedGroup {
    <#
    .SYNOPSIS
        Assign an RBAC v2 role to one or more groups.

    .DESCRIPTION
        Assigns the role to the given groups via the
        /v1/rbac_roles/{id}/groups endpoint (POST). This is the role-side way
        to manage assignments; the group-side equivalent is
        Add-EvoGroupRbacRole.

        Built-in (stock) roles are assignable even though they cannot be edited.

    .PARAMETER RbacRoleId
        ID (selector UUID) of the role.

    .PARAMETER GroupIdList
        One or more group IDs (selector UUIDs).

    .EXAMPLE
        Add-EvoRbacRoleAssignedGroup -RbacRoleId $role.id -GroupIdList $ids

        Assigns the role to the listed groups.
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
        if (-not $PSCmdlet.ShouldProcess("RBAC role '$RbacRoleId'", 'Assign groups')) {
            return
        }

        $body = @{
            groupIds = $GroupIdList
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path "/v1/rbac_roles/$RbacRoleId/groups" -Body $body
        Write-Output $response
    }
}
