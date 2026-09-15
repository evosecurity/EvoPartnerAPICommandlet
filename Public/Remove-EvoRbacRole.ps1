function Remove-EvoRbacRole {
    <#
    .SYNOPSIS
        Delete an RBAC v2 role.

    .DESCRIPTION
        Deletes a role via the /v1/rbac_roles/{id} endpoint. Built-in (stock)
        roles are not deletable and the API rejects the request.

    .PARAMETER Id
        ID (selector UUID) of the role to delete.

    .EXAMPLE
        Remove-EvoRbacRole -Id $role.id

        Deletes the role after prompting for confirmation.

    .EXAMPLE
        Remove-EvoRbacRole -Id $role.id -Confirm:$false

        Deletes the role without prompting.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('RbacRoleId')]
        [string]$Id
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("RBAC role '$Id'", 'Delete')) {
            return
        }

        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path "/v1/rbac_roles/$Id"
        Write-Output $response
    }
}
