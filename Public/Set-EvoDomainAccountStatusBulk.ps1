function Set-EvoDomainAccountStatusBulk {
    <#
    .SYNOPSIS
        Bulk update domain account status (enable/disable).

    .DESCRIPTION
        Updates the active status of multiple domain accounts via the
        /v1/domain_accounts/bulk-status endpoint.

    .PARAMETER DomainAccountIdList
        One or more domain account IDs to update.

    .PARAMETER Active
        Whether the accounts should be active (true) or disabled (false).

    .EXAMPLE
        Set-EvoDomainAccountStatusBulk -DomainAccountIdList 'id1', 'id2' -Active $false

        Disables multiple domain accounts.

    .EXAMPLE
        Get-EvoDomainAccount -Type manual | Set-EvoDomainAccountStatusBulk -Active $true

        Enables all manual domain accounts.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id', 'DomainAccountId')]
        [string[]]$DomainAccountIdList,

        [Parameter(Mandatory = $true)]
        [bool]$Active
    )

    begin {
        $buffer = New-Object System.Collections.Generic.List[string]
    }

    process {
        foreach ($id in $DomainAccountIdList) {
            if (-not [string]::IsNullOrWhiteSpace($id)) {
                $buffer.Add($id)
            }
        }
    }

    end {
        if ($buffer.Count -eq 0) {
            return
        }

        $action = if ($Active) { 'Enable' } else { 'Disable' }
        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) domain accounts", $action)) {
            return
        }

        $body = @{
            domainAccountIds = $buffer.ToArray()
            active = $Active
        }

        $response = Invoke-EvoApiRequest -Method 'PUT' -Path '/v1/domain_accounts/bulk/status' -Body $body
        Write-Output $response
    }
}
