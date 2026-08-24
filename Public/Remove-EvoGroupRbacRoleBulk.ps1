function Remove-EvoGroupRbacRoleBulk {
    <#
    .SYNOPSIS
        Bulk unassign RBAC v2 roles from multiple groups.

    .DESCRIPTION
        Calls the /v1/groups/bulk/rbac_roles endpoint (DELETE). Accepts
        group/role mappings from the pipeline and sends them as the groups
        array required by the API.

        Partial success is normal: the response carries the successful entries
        plus a failedItems array describing the rest.

    .PARAMETER GroupRbacRole
        Objects describing the mapping between a group and the roles to
        unassign. Each object should contain GroupId and RbacRoleIds
        properties.

    .EXAMPLE
        $map = @(
            [pscustomobject]@{ GroupId = $a.id; RbacRoleIds = @($role.id) }
            [pscustomobject]@{ GroupId = $b.id; RbacRoleIds = @($role.id) }
        )
        $map | Remove-EvoGroupRbacRoleBulk

        Unassigns one role from two groups in a single request.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [psobject]$GroupRbacRole
    )

    begin {
        $buffer = New-Object System.Collections.Generic.List[object]
    }

    process {
        if ($null -ne $GroupRbacRole) {
            $buffer.Add($GroupRbacRole)
        }
    }

    end {
        if ($buffer.Count -eq 0) {
            return
        }

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) group role mappings", 'Bulk unassign RBAC roles')) {
            return
        }

        $payload = @()
        foreach ($item in $buffer) {
            $payload += @{
                groupId = $item.GroupId
                roleIds   = @($item.RbacRoleIds)
            }
        }

        $body = @{
            groups = $payload
        }

        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path '/v1/groups/bulk/rbac_roles' -Body $body
        Write-Output $response
    }
}
