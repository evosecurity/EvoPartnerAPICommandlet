function Add-EvoUserRoleGroupBulk {
    <#
    .SYNOPSIS
        Bulk add role groups to multiple users.

    .DESCRIPTION
        Calls the /v1/users/bulk/role_groups POST endpoint. Accepts
        user/role-group mappings from the pipeline and sends them as the
        userRoleGroups array required by the API.

    .PARAMETER UserRoleGroup
        Objects describing the mapping between a user and the role
        groups to add. Each object should contain UserId and
        RoleGroupIds properties.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [psobject]$UserRoleGroup
    )

    begin {
        $buffer = New-Object System.Collections.Generic.List[object]
    }

    process {
        if ($null -ne $UserRoleGroup) {
            $buffer.Add($UserRoleGroup)
        }
    }

    end {
        if ($buffer.Count -eq 0) {
            return
        }

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) user role-group mappings", 'Bulk add role groups')) {
            return
        }

        $payload = @()
        foreach ($item in $buffer) {
            $entry = @{
                userId      = $item.UserId
                roleGroupIds = @($item.RoleGroupIds)
            }
            $payload += $entry
        }

        $body = @{
            userRoleGroups = $payload
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/users/bulk/role_groups' -Body $body
        Write-Output $response
    }
}
