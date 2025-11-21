function New-EvoTenantBulk {
    <#
    .SYNOPSIS
        Bulk create tenants.

    .DESCRIPTION
        Creates multiple tenants via the /v1/tenants/bulk endpoint.

    .PARAMETER Tenant
        Tenant definition objects. Each should contain a Name property.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [psobject]$Tenant
    )

    begin {
        $buffer = New-Object System.Collections.Generic.List[object]
    }

    process {
        if ($null -ne $Tenant) {
            $buffer.Add($Tenant)
        }
    }

    end {
        if ($buffer.Count -eq 0) {
            return
        }

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) tenants", 'Bulk create')) {
            return
        }

        $payload = @()
        foreach ($t in $buffer) {
            $item = @{ name = $t.Name }
            $payload += $item
        }

        $body = @{ tenants = $payload }
        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/tenants/bulk' -Body $body
        Write-Output $response
    }
}
