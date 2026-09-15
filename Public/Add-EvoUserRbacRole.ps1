function Add-EvoUserRbacRole {
    <#
    .SYNOPSIS
        Assign RBAC v2 roles to a user.

    .DESCRIPTION
        Assigns the given roles to a user via the
        /v1/users/{id}/rbac_roles endpoint (POST). This is the RBAC v2
        counterpart to the legacy Add-EvoUserRoleGroup cmdlet.

    .PARAMETER UserId
        ID (selector UUID) of the user.

    .PARAMETER RbacRoleIdList
        One or more role IDs (selector UUIDs).

    .EXAMPLE
        Add-EvoUserRbacRole -UserId $user.id -RbacRoleIdList $role.id

        Assigns a single role to the user.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$UserId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('RbacRoleIds')]
        [string[]]$RbacRoleIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("User '$UserId'", 'Assign RBAC roles')) {
            return
        }

        $body = @{
            roleIds = $RbacRoleIdList
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path "/v1/users/$UserId/rbac_roles" -Body $body
        Write-Output $response
    }
}
