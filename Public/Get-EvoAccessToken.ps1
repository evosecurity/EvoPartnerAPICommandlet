function Get-EvoAccessToken {
    <#
    .SYNOPSIS
        Get access tokens for the current environment.

    .DESCRIPTION
        Retrieves access tokens via the /v1/access_tokens and
        /v1/access_tokens/{id} endpoints. Supports filtering when
        listing tokens.

        Note: LDAP agent tokens never expire (expireAt is null). When filtering
        with Expired = 'false', both non-expired tokens and LDAP agent tokens
        (which never expire) are returned.

    .PARAMETER Id
        The ID of the access token to retrieve.

    .PARAMETER Page
        Page number for the results when listing access tokens.

    .PARAMETER Limit
        Number of items per page.

    .PARAMETER Query
        Optional search term applied to token name.

    .PARAMETER Active
        Optional filter for active status: 'true' or 'false'.

    .PARAMETER Expired
        Optional filter for expiration status: 'true' or 'false'.
        - 'true': Returns only expired tokens (excludes LDAP agent tokens which never expire)
        - 'false': Returns non-expired tokens AND LDAP agent tokens (which never expire)

    .PARAMETER TenantIdList
        Optional list of tenant IDs to filter tokens by.

    .PARAMETER DirectoryIdList
        Optional list of directory IDs to filter tokens by.

    .PARAMETER Type
        Optional filter for token type: endpoint_agent or ldap_agent.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('AccessTokenId')]
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
        [ValidateSet('true','false')]
        [string]$Expired,

        [Parameter(ParameterSetName = 'List')]
        [string[]]$TenantIdList,

        [Parameter(ParameterSetName = 'List')]
        [string[]]$DirectoryIdList,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('endpoint_agent','ldap_agent')]
        [string]$Type
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $path = "/v1/access_tokens/$Id"
            $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                $token = $response.data
                if ($token -is [pscustomobject]) {
                    $token.PSObject.TypeNames.Insert(0, 'Evo.AccessToken')
                }
                return $token
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

        if ($PSBoundParameters.ContainsKey('Expired') -and $Expired) {
            $queryParams['expired'] = $Expired
        }

        if ($TenantIdList) {
            $queryParams['tenantIds[]'] = $TenantIdList
        }

        if ($DirectoryIdList) {
            $queryParams['directoryIds[]'] = $DirectoryIdList
        }

        if ($PSBoundParameters.ContainsKey('Type') -and $Type) {
            $queryParams['type'] = $Type
        }

        $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/access_tokens' -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($token in $response.data) {
                if ($token -is [pscustomobject]) {
                    $token.PSObject.TypeNames.Insert(0, 'Evo.AccessToken')
                }
                Write-Output $token
            }
        }
        else {
            Write-Output $response
        }
    }
}
