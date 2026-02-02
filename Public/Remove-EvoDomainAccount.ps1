function Remove-EvoDomainAccount {
    <#
    .SYNOPSIS
        Delete a domain account.

    .DESCRIPTION
        Deletes a domain account via the /v1/domain_accounts/{id} endpoint.
        This operation is asynchronous and returns an operation ID.

    .PARAMETER Id
        The ID of the domain account to delete.

    .EXAMPLE
        Remove-EvoDomainAccount -Id 'account-id'

        Deletes the domain account with the specified ID.

    .EXAMPLE
        Get-EvoDomainAccount -Type manual | Remove-EvoDomainAccount

        Deletes all manual domain accounts.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('DomainAccountId')]
        [string]$Id
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Domain account $Id", 'Delete')) {
            return
        }

        $path = "/v1/domain_accounts/$Id"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path
        Write-Output $response
    }
}
