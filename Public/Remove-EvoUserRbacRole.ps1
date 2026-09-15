function Remove-EvoUserRbacRole {
    <#
    .SYNOPSIS
        Unassign RBAC v2 roles from a user.

    .DESCRIPTION
        Unassigns the given roles from a user via the
        /v1/users/{id}/rbac_roles endpoint (DELETE). This is the RBAC v2
        counterpart to the legacy Remove-EvoUserRoleGroup cmdlet.

    .PARAMETER UserId
        ID (selector UUID) of the user.

    .PARAMETER RbacRoleIdList
        One or more role IDs (selector UUIDs).

    .EXAMPLE
        Remove-EvoUserRbacRole -UserId $user.id -RbacRoleIdList $role.id

        Unassigns a single role from the user.
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
        if (-not $PSCmdlet.ShouldProcess("User '$UserId'", 'Unassign RBAC roles')) {
            return
        }

        $body = @{
            roleIds = $RbacRoleIdList
        }

        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path "/v1/users/$UserId/rbac_roles" -Body $body
        Write-Output $response
    }
}
