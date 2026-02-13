function New-EvoDomainAccountManual {
    <#
    .SYNOPSIS
        Create a new manual domain account.

    .DESCRIPTION
        Creates a new manual domain account via the /v1/domain_accounts/manual endpoint.
        This operation is asynchronous and returns an operation ID.

    .PARAMETER Username
        The username for the domain account.

    .PARAMETER Password
        The password for the domain account.

    .PARAMETER TenantId
        The ID of the tenant to associate with the domain account.

    .PARAMETER Domain
        Optional domain name for the account.

    .PARAMETER Active
        Whether the account should be active. Defaults to true.

    .EXAMPLE
        New-EvoDomainAccountManual -Username 'admin' -Password 'SecurePass123!' -TenantId 'tenant-id'

        Creates a new manual domain account.

    .EXAMPLE
        New-EvoDomainAccountManual -Username 'admin' -Password 'SecurePass123!' -TenantId 'tenant-id' -Domain 'contoso.com'

        Creates a new manual domain account with a specific domain.

    .EXAMPLE
        $result = New-EvoDomainAccountManual -Username 'admin' -Password 'SecurePass123!' -TenantId 'tenant-id'
        $operation = Get-EvoAsyncOperation -Id $result.operationId
        $domainAccountId = $operation.result.domainAccountId

        Creates a manual domain account and uses the operationId to get the async operation
        details via the /v1/async_operations/{id} endpoint. Once the operation completes,
        the result contains the domain account ID.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Username,

        [Parameter(Mandatory = $true)]
        [string]$Password,

        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter()]
        [string]$Domain,

        [Parameter()]
        [bool]$Active = $true
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Manual domain account $Username", 'Create')) {
            return
        }

        $body = @{
            username = $Username
            password = $Password
            tenantId = $TenantId
            active = $Active
        }

        if ($PSBoundParameters.ContainsKey('Domain') -and $Domain) {
            $body['domain'] = $Domain
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/domain_accounts/manual' -Body $body
        
        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            Write-Output $response.data
        }
        else {
            Write-Output $response
        }
    }
}
