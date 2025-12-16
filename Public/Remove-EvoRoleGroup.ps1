function Remove-EvoRoleGroup {
    <#
    .SYNOPSIS
        Delete a role group.

    .DESCRIPTION
        Deletes a role group via the /v1/role_groups/{id} endpoint. This also
        removes all role-based assignments for users and groups that were
        assigned to this role group, as well as any directory sync
        configuration role group members.

    .PARAMETER Id
        The ID of the role group to delete.

    .EXAMPLE
        Remove-EvoRoleGroup -Id 'role-group-id' -Confirm:$false

        Deletes the specified role group without confirmation.

    .EXAMPLE
        Get-EvoRoleGroup -Query 'Test' | Remove-EvoRoleGroup

        Deletes all role groups matching 'Test' (with confirmation).
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('RoleGroupId')]
        [string]$Id
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Role group $Id", 'Delete')) {
            return
        }

        $path = "/v1/role_groups/$Id"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path

        Write-Output $response
    }
}
