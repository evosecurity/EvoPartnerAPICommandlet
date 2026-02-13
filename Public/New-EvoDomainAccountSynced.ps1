function New-EvoDomainAccountSynced {
    <#
    .SYNOPSIS
        Create a new synced domain account.

    .DESCRIPTION
        Creates a new synced domain account via the /v1/domain_accounts/synced endpoint.
        This operation is asynchronous and returns an operation ID.

    .PARAMETER UserId
        The ID of the user to sync as a domain account.

    .PARAMETER Interval
        Optional password rotation interval in days.

    .PARAMETER Active
        Whether the account should be active. Defaults to true.

    .EXAMPLE
        New-EvoDomainAccountSynced -UserId 'user-id'

        Creates a new synced domain account from a user.

    .EXAMPLE
        New-EvoDomainAccountSynced -UserId 'user-id' -Interval 30

        Creates a new synced domain account with 30-day password rotation.

    .EXAMPLE
        $result = New-EvoDomainAccountSynced -UserId 'user-id'
        $operation = Get-EvoAsyncOperation -Id $result.operationId
        $domainAccountId = $operation.result.domainAccountId

        Creates a synced domain account and uses the operationId to get the async operation
        details via the /v1/async_operations/{id} endpoint. Once the operation completes,
        the result contains the domain account ID.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$UserId,

        [Parameter()]
        [int]$Interval,

        [Parameter()]
        [bool]$Active = $true
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Synced domain account for user $UserId", 'Create')) {
            return
        }

        $body = @{
            userId = $UserId
            active = $Active
        }

        if ($PSBoundParameters.ContainsKey('Interval')) {
            $body['interval'] = $Interval
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/domain_accounts/synced' -Body $body
        
        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            Write-Output $response.data
        }
        else {
            Write-Output $response
        }
    }
}
