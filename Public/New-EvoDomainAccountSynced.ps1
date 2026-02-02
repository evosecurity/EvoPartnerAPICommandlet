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
        Write-Output $response
    }
}
