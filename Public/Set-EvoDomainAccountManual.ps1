function Set-EvoDomainAccountManual {
    <#
    .SYNOPSIS
        Update a manual domain account.

    .DESCRIPTION
        Updates a manual domain account via the /v1/domain_accounts/{id}/manual endpoint.
        This operation is asynchronous and returns an operation ID.

    .PARAMETER Id
        The ID of the domain account to update.

    .PARAMETER Password
        Optional new password for the account.

    .PARAMETER Domain
        Optional new domain for the account.

    .PARAMETER Active
        Optional active status for the account.

    .EXAMPLE
        Set-EvoDomainAccountManual -Id 'account-id' -Password 'NewSecurePass123!'

        Updates the password for a manual domain account.

    .EXAMPLE
        Set-EvoDomainAccountManual -Id 'account-id' -Active $false

        Disables a manual domain account.

    .EXAMPLE
        $result = Set-EvoDomainAccountManual -Id 'account-id' -Password 'NewSecurePass123!'
        Get-EvoAsyncOperation -Id $result.operationId

        Updates a manual domain account password and uses the operationId to check the
        async operation status via the /v1/async_operations/{id} endpoint.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('DomainAccountId')]
        [string]$Id,

        [Parameter()]
        [string]$Password,

        [Parameter()]
        [string]$Domain,

        [Parameter()]
        [bool]$Active
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Manual domain account $Id", 'Update')) {
            return
        }

        $body = @{}

        if ($PSBoundParameters.ContainsKey('Password') -and $Password) {
            $body['password'] = $Password
        }

        if ($PSBoundParameters.ContainsKey('Domain')) {
            $body['domain'] = $Domain
        }

        if ($PSBoundParameters.ContainsKey('Active')) {
            $body['active'] = $Active
        }

        if ($body.Count -eq 0) {
            throw 'At least one parameter (Password, Domain, or Active) must be specified.'
        }

        $path = "/v1/domain_accounts/$Id/manual"
        $response = Invoke-EvoApiRequest -Method 'PUT' -Path $path -Body $body
        
        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            Write-Output $response.data
        }
        else {
            Write-Output $response
        }
    }
}
