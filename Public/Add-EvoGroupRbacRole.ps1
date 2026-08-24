function Add-EvoGroupRbacRole {
    <#
    .SYNOPSIS
        Assign RBAC v2 roles to a group.

    .DESCRIPTION
        Assigns the given roles to a group via the
        /v1/groups/{id}/rbac_roles endpoint (POST). This is the RBAC v2
        counterpart to the legacy Add-EvoGroupRoleGroup cmdlet.

    .PARAMETER GroupId
        ID (selector UUID) of the group.

    .PARAMETER RbacRoleIdList
        One or more role IDs (selector UUIDs).

    .EXAMPLE
        Add-EvoGroupRbacRole -GroupId $group.id -RbacRoleIdList $role.id

        Assigns a single role to the group.
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
        if (-not $PSCmdlet.ShouldProcess("Group '$GroupId'", 'Assign RBAC roles')) {
            return
        }

        $body = @{
            roleIds = $RbacRoleIdList
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path "/v1/groups/$GroupId/rbac_roles" -Body $body
        Write-Output $response
    }
}
