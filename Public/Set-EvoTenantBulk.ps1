function Set-EvoTenantBulk {
    <#
    .SYNOPSIS
        Bulk update tenant display names.

    .DESCRIPTION
        Updates multiple tenants via the /v1/tenants/bulk PUT endpoint.

    .PARAMETER Tenant
        Tenant update objects. Each should contain Id and DisplayName
        properties.
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

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) tenants", 'Bulk update')) {
            return
        }

        $payload = @()
        foreach ($t in $buffer) {
            $item = @{ id = $t.Id; displayName = $t.DisplayName }
            $payload += $item
        }

        $body = @{ tenants = $payload }
        $response = Invoke-EvoApiRequest -Method 'PUT' -Path '/v1/tenants/bulk' -Body $body
        Write-Output $response
    }
}
