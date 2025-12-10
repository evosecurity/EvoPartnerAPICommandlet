function Get-EvoLocalAdminAccount {
    <#
    .SYNOPSIS
        Get local admin accounts for the current environment.

    .DESCRIPTION
        Retrieves local admin accounts via the /v1/local_admin_accounts
        endpoint. Supports pagination, searching, and filtering.

    .PARAMETER Id
        Optional ID of a specific local admin account to retrieve.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .PARAMETER Query
        Search term to filter accounts by username or hostname.

    .PARAMETER TenantIdList
        Filter accounts by one or more tenant IDs.

    .PARAMETER ComputerIdList
        Filter accounts by one or more computer (desktop endpoint) IDs.

    .PARAMETER Enabled
        Filter accounts by enabled status.

    .EXAMPLE
        Get-EvoLocalAdminAccount

        Retrieves all local admin accounts.

    .EXAMPLE
        Get-EvoLocalAdminAccount -Id 'account-id'

        Retrieves a specific local admin account.

    .EXAMPLE
        Get-EvoLocalAdminAccount -Query 'admin' -TenantIdList @('tenant-id-1')

        Retrieves local admin accounts matching 'admin' for a specific tenant.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'Single', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('LocalAdminAccountId')]
        [string]$Id,

        [Parameter(ParameterSetName = 'List')]
        [Nullable[int]]$Page,

        [Parameter(ParameterSetName = 'List')]
        [Nullable[int]]$Limit,

        [Parameter(ParameterSetName = 'List')]
        [Alias('Q')]
        [string]$Query,

        [Parameter(ParameterSetName = 'List')]
        [Alias('TenantIds')]
        [string[]]$TenantIdList,

        [Parameter(ParameterSetName = 'List')]
        [Alias('ComputerIds')]
        [string[]]$ComputerIdList,

        [Parameter(ParameterSetName = 'List')]
        [Nullable[bool]]$Enabled
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Single') {
            $path = "/v1/local_admin_accounts/$Id"
            $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

            if ($response.data) {
                $account = $response.data

                if ($account -is [pscustomobject]) {
                    $account.PSObject.TypeNames.Insert(0, 'Evo.LocalAdminAccount')
                }

                Write-Output $account
            }
            else {
                Write-Output $response
            }
        }
        else {
            $currentPage = if ($Page -ne $null) { $Page } else { 1 }
            $pageSize = if ($Limit -ne $null) { $Limit } else { $script:EvoPartnerApiConfig.DefaultPageSize }

            if ($pageSize -le 0) {
                throw 'Limit must be greater than zero.'
            }

            $queryParams = @{
                page  = $currentPage
                limit = $pageSize
            }

            if ($PSBoundParameters.ContainsKey('Query') -and $Query) {
                $queryParams['q'] = $Query
            }

            if ($PSBoundParameters.ContainsKey('TenantIdList') -and $TenantIdList) {
                $queryParams['tenantIds[]'] = $TenantIdList
            }

            if ($PSBoundParameters.ContainsKey('ComputerIdList') -and $ComputerIdList) {
                $queryParams['computerIds[]'] = $ComputerIdList
            }

            if ($PSBoundParameters.ContainsKey('Enabled')) {
                $queryParams['enabled'] = $Enabled
            }

            $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/local_admin_accounts' -Query $queryParams

            if ($response.data) {
                foreach ($account in $response.data) {
                    if ($account -is [pscustomobject]) {
                        $account.PSObject.TypeNames.Insert(0, 'Evo.LocalAdminAccount')
                    }
                    Write-Output $account
                }
            }
            else {
                Write-Output $response
            }
        }
    }
}
