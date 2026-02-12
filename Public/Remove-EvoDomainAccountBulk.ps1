function Remove-EvoDomainAccountBulk {
    <#
    .SYNOPSIS
        Bulk delete domain accounts.

    .DESCRIPTION
        Deletes multiple domain accounts via the /v1/domain_accounts/bulk endpoint.
        This operation is asynchronous and returns operation details.

    .PARAMETER DomainAccountIdList
        One or more domain account IDs to delete.

    .EXAMPLE
        Remove-EvoDomainAccountBulk -DomainAccountIdList 'id1', 'id2', 'id3'

        Deletes multiple domain accounts by their IDs.

    .EXAMPLE
        Get-EvoDomainAccount -Type manual -Active false | Remove-EvoDomainAccountBulk

        Deletes all inactive manual domain accounts.

    .EXAMPLE
        $result = Remove-EvoDomainAccountBulk -DomainAccountIdList 'id1', 'id2', 'id3'
        Get-EvoAsyncOperation -Id $result.operationId

        Bulk deletes domain accounts and uses the operationId to check the async operation
        status via the /v1/async_operations/{id} endpoint.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id', 'DomainAccountId')]
        [string[]]$DomainAccountIdList
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

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) domain accounts", 'Bulk delete')) {
            return
        }

        $body = @{
            domainAccountIds = $buffer.ToArray()
        }

        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path '/v1/domain_accounts/bulk' -Body $body
        
        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            Write-Output $response.data
        }
        else {
            Write-Output $response
        }
    }
}
