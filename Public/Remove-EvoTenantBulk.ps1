function Remove-EvoTenantBulk {
    <#
    .SYNOPSIS
        Bulk delete tenants.

    .DESCRIPTION
        Deletes multiple tenants via the /v1/tenants/bulk DELETE
        endpoint.

    .PARAMETER TenantIdList
        One or more tenant IDs to delete.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$TenantIdList
    )

    begin {
        $buffer = New-Object System.Collections.Generic.List[string]
    }

    process {
        foreach ($id in $TenantIdList) {
            if (-not [string]::IsNullOrWhiteSpace($id)) {
                $buffer.Add($id)
            }
        }
    }

    end {
        if ($buffer.Count -eq 0) {
            return
        }

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) tenants", 'Bulk delete')) {
            return
        }

        $body = @{ tenantIds = $buffer.ToArray() }
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path '/v1/tenants/bulk' -Body $body
        Write-Output $response
    }
}
