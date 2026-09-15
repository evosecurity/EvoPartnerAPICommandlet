function Remove-EvoUserRbacRoleBulk {
    <#
    .SYNOPSIS
        Bulk unassign RBAC v2 roles from multiple users.

    .DESCRIPTION
        Calls the /v1/users/bulk/rbac_roles endpoint (DELETE). Accepts
        user/role mappings from the pipeline and sends them as the userRoles
        array required by the API.

        Partial success is normal: the response carries the successful entries
        plus a failedItems array describing the rest.

    .PARAMETER UserRbacRole
        Objects describing the mapping between a user and the roles to
        unassign. Each object should contain UserId and RbacRoleIds
        properties.

    .EXAMPLE
        $map = @(
            [pscustomobject]@{ UserId = $a.id; RbacRoleIds = @($role.id) }
            [pscustomobject]@{ UserId = $b.id; RbacRoleIds = @($role.id) }
        )
        $map | Remove-EvoUserRbacRoleBulk

        Unassigns one role from two users in a single request.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [psobject]$UserRbacRole
    )

    begin {
        $buffer = New-Object System.Collections.Generic.List[object]
    }

    process {
        if ($null -ne $UserRbacRole) {
            $buffer.Add($UserRbacRole)
        }
    }

    end {
        if ($buffer.Count -eq 0) {
            return
        }

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) user role mappings", 'Bulk unassign RBAC roles')) {
            return
        }

        $payload = @()
        foreach ($item in $buffer) {
            $payload += @{
                userId = $item.UserId
                roleIds   = @($item.RbacRoleIds)
            }
        }

        $body = @{
            userRoles = $payload
        }

        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path '/v1/users/bulk/rbac_roles' -Body $body
        Write-Output $response
    }
}
