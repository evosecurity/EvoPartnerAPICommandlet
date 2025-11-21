function Remove-EvoUserRoleGroup {
    <#
    .SYNOPSIS
        Remove role groups from a user.

    .DESCRIPTION
        Calls the /v1/users/{id}/role_groups DELETE endpoint to remove
        one or more role groups from the specified user.

    .PARAMETER UserId
        The ID of the user.

    .PARAMETER RoleGroupIdList
        One or more role group IDs to remove from the user.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$UserId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$RoleGroupIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("User $UserId", 'Remove role groups')) {
            return
        }

        $body = @{
            roleGroupIds = $RoleGroupIdList
        }

        $path = "/v1/users/$UserId/role_groups"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path -Body $body
        Write-Output $response
    }
}
