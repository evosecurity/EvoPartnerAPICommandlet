function Add-EvoUserRoleGroup {
    <#
    .SYNOPSIS
        Add role groups to a user.

    .DESCRIPTION
        Calls the /v1/users/{id}/role_groups POST endpoint to add one or
        more role groups to the specified user.

    .PARAMETER UserId
        The ID of the user.

    .PARAMETER RoleGroupIdList
        One or more role group IDs to add to the user.
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
        if (-not $PSCmdlet.ShouldProcess("User $UserId", 'Add role groups')) {
            return
        }

        $body = @{
            roleGroupIds = $RoleGroupIdList
        }

        $path = "/v1/users/$UserId/role_groups"
        $response = Invoke-EvoApiRequest -Method 'POST' -Path $path -Body $body
        Write-Output $response
    }
}
