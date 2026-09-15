function Remove-EvoRbacRoleAssignedUser {
    <#
    .SYNOPSIS
        Unassign an RBAC v2 role from one or more users.

    .DESCRIPTION
        Unassigns the role from the given users via the
        /v1/rbac_roles/{id}/users endpoint (DELETE). This is the role-side way
        to manage assignments; the user-side equivalent is
        Remove-EvoUserRbacRole.

        Built-in (stock) roles are assignable even though they cannot be edited.

    .PARAMETER RbacRoleId
        ID (selector UUID) of the role.

    .PARAMETER UserIdList
        One or more user IDs (selector UUIDs).

    .EXAMPLE
        Remove-EvoRbacRoleAssignedUser -RbacRoleId $role.id -UserIdList $ids

        Unassigns the role from the listed users.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$RbacRoleId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('UserIds')]
        [string[]]$UserIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("RBAC role '$RbacRoleId'", 'Unassign users')) {
            return
        }

        $body = @{
            userIds = $UserIdList
        }

        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path "/v1/rbac_roles/$RbacRoleId/users" -Body $body
        Write-Output $response
    }
}
