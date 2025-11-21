function Add-EvoGroupRoleGroupBulk {
    <#
    .SYNOPSIS
        Bulk add role groups to multiple groups.

    .DESCRIPTION
        Calls the /v1/groups/bulk/role_groups POST endpoint. Accepts
        group/role-group mappings from the pipeline and sends them as
        the groups array required by the API.

    .PARAMETER GroupRoleGroup
        Objects describing the mapping between a group and the role
        groups to add. Each object should contain GroupId and
        RoleGroupIds properties.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [psobject]$GroupRoleGroup
    )

    begin {
        $buffer = New-Object System.Collections.Generic.List[object]
    }

    process {
        if ($null -ne $GroupRoleGroup) {
            $buffer.Add($GroupRoleGroup)
        }
    }

    end {
        if ($buffer.Count -eq 0) {
            return
        }

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) group role-group mappings", 'Bulk add role groups')) {
            return
        }

        $payload = @()
        foreach ($item in $buffer) {
            $entry = @{
                groupId     = $item.GroupId
                roleGroupIds = @($item.RoleGroupIds)
            }
            $payload += $entry
        }

        $body = @{
            groups = $payload
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/groups/bulk/role_groups' -Body $body
        Write-Output $response
    }
}
