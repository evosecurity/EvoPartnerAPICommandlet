function Get-EvoDomainAccount {
    <#
    .SYNOPSIS
        Get domain accounts for the current environment.

    .DESCRIPTION
        Retrieves domain accounts via the /v1/domain_accounts and
        /v1/domain_accounts/{id} endpoints.

    .PARAMETER Id
        The ID of the domain account to retrieve.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .PARAMETER Query
        Optional search term applied to username.

    .PARAMETER Active
        Optional filter for active status: 'true' or 'false'.

    .PARAMETER Type
        Optional filter for account type: manual or synced.

    .PARAMETER DirectoryIdList
        Optional list of directory IDs to filter accounts by.

    .PARAMETER TenantIdList
        Optional list of tenant IDs to filter accounts by.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('DomainAccountId')]
        [string]$Id,

        [Parameter(ParameterSetName = 'List')]
        [int]$Page,

        [Parameter(ParameterSetName = 'List')]
        [int]$Limit,

        [Parameter(ParameterSetName = 'List')]
        [Alias('Q')]
        [string]$Query,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('true','false')]
        [string]$Active,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('manual','synced')]
        [string]$Type,

        [Parameter(ParameterSetName = 'List')]
        [string[]]$DirectoryIdList,

        [Parameter(ParameterSetName = 'List')]
        [string[]]$TenantIdList
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $path = "/v1/domain_accounts/$Id"
            $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                $account = $response.data
                if ($account -is [pscustomobject]) {
                    $account.PSObject.TypeNames.Insert(0, 'Evo.DomainAccount')
                }
                return $account
            }

            return $response
        }

        $currentPage = if ($PSBoundParameters.ContainsKey('Page')) { $Page } else { 1 }
        $pageSize = if ($PSBoundParameters.ContainsKey('Limit')) { $Limit } else { $script:EvoPartnerApiConfig.DefaultPageSize }

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

        if ($PSBoundParameters.ContainsKey('Active') -and $Active) {
            $queryParams['active'] = $Active
        }

        if ($PSBoundParameters.ContainsKey('Type') -and $Type) {
            $queryParams['type'] = $Type
        }

        if ($DirectoryIdList) {
            $queryParams['directoryIds[]'] = $DirectoryIdList
        }

        if ($TenantIdList) {
            $queryParams['tenantIds[]'] = $TenantIdList
        }

        $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/domain_accounts' -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($account in $response.data) {
                if ($account -is [pscustomobject]) {
                    $account.PSObject.TypeNames.Insert(0, 'Evo.DomainAccount')
                }
                Write-Output $account
            }
        }
        else {
            Write-Output $response
        }
    }
}
