function New-EvoGroupBulk {
    <#
    .SYNOPSIS
        Bulk create manual user groups.

    .DESCRIPTION
        Creates multiple groups via the /v1/groups/bulk endpoint.
        Accepts group definitions from the pipeline and sends them as
        the groups array required by the API.

    .PARAMETER Group
        Group definition objects. Each should contain TenantId and Name,
        and may include Description and UserIds.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [psobject]$Group
    )

    begin {
        $buffer = New-Object System.Collections.Generic.List[object]
    }

    process {
        if ($null -ne $Group) {
            $buffer.Add($Group)
        }
    }

    end {
        if ($buffer.Count -eq 0) {
            return
        }

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) groups", 'Bulk create')) {
            return
        }

        $payload = @()
        foreach ($g in $buffer) {
            $item = @{
                tenantId = $g.TenantId
                name     = $g.Name
            }

            if ($g.PSObject.Properties['Description'] -and $g.Description) {
                $item['description'] = $g.Description
            }

            if ($g.PSObject.Properties['UserIds'] -and $g.UserIds) {
                $item['userIds'] = @($g.UserIds)
            }

            $payload += $item
        }

        $body = @{
            groups = $payload
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/groups/bulk' -Body $body
        Write-Output $response
    }
}
