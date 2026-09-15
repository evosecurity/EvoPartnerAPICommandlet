function Add-EvoUserRbacRoleBulk {
    <#
    .SYNOPSIS
        Bulk assign RBAC v2 roles to multiple users.

    .DESCRIPTION
        Calls the /v1/users/bulk/rbac_roles endpoint (POST). Accepts
        user/role mappings from the pipeline and sends them as the userRoles
        array required by the API.

        Partial success is normal: the response carries the successful entries
        plus a failedItems array describing the rest.

    .PARAMETER UserRbacRole
        Objects describing the mapping between a user and the roles to
        assign. Each object should contain UserId and RbacRoleIds
        properties.

    .EXAMPLE
        $map = @(
            [pscustomobject]@{ UserId = $a.id; RbacRoleIds = @($role.id) }
            [pscustomobject]@{ UserId = $b.id; RbacRoleIds = @($role.id) }
        )
        $map | Add-EvoUserRbacRoleBulk

        Assigns one role to two users in a single request.
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

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) user role mappings", 'Bulk assign RBAC roles')) {
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

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/users/bulk/rbac_roles' -Body $body
        Write-Output $response
    }
}
