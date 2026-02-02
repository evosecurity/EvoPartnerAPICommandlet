function Set-EvoDomainAccountSynced {
    <#
    .SYNOPSIS
        Update a synced domain account.

    .DESCRIPTION
        Updates a synced domain account via the /v1/domain_accounts/{id}/synced endpoint.
        This operation is asynchronous and returns an operation ID.

    .PARAMETER Id
        The ID of the domain account to update.

    .PARAMETER Interval
        Optional new password rotation interval in days.

    .PARAMETER Active
        Optional active status for the account.

    .EXAMPLE
        Set-EvoDomainAccountSynced -Id 'account-id' -Interval 60

        Updates the password rotation interval to 60 days.

    .EXAMPLE
        Set-EvoDomainAccountSynced -Id 'account-id' -Active $false

        Disables a synced domain account.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('DomainAccountId')]
        [string]$Id,

        [Parameter()]
        [int]$Interval,

        [Parameter()]
        [bool]$Active
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Synced domain account $Id", 'Update')) {
            return
        }

        $body = @{}

        if ($PSBoundParameters.ContainsKey('Interval')) {
            $body['interval'] = $Interval
        }

        if ($PSBoundParameters.ContainsKey('Active')) {
            $body['active'] = $Active
        }

        if ($body.Count -eq 0) {
            throw 'At least one parameter (Interval or Active) must be specified.'
        }

        $path = "/v1/domain_accounts/$Id/synced"
        $response = Invoke-EvoApiRequest -Method 'PUT' -Path $path -Body $body
        Write-Output $response
    }
}
