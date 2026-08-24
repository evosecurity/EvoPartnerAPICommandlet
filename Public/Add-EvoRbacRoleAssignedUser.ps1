function Add-EvoRbacRoleAssignedUser {
    <#
    .SYNOPSIS
        Assign an RBAC v2 role to one or more users.

    .DESCRIPTION
        Assigns the role to the given users via the
        /v1/rbac_roles/{id}/users endpoint (POST). This is the role-side way
        to manage assignments; the user-side equivalent is
        Add-EvoUserRbacRole.

        Built-in (stock) roles are assignable even though they cannot be edited.

    .PARAMETER RbacRoleId
        ID (selector UUID) of the role.

    .PARAMETER UserIdList
        One or more user IDs (selector UUIDs).

    .EXAMPLE
        Add-EvoRbacRoleAssignedUser -RbacRoleId $role.id -UserIdList $ids

        Assigns the role to the listed users.
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
        if (-not $PSCmdlet.ShouldProcess("RBAC role '$RbacRoleId'", 'Assign users')) {
            return
        }

        $body = @{
            userIds = $UserIdList
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path "/v1/rbac_roles/$RbacRoleId/users" -Body $body
        Write-Output $response
    }
}
