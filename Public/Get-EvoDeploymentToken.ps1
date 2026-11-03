function Get-EvoDeploymentToken {
    <#
    .SYNOPSIS
        Get deployment tokens for the current environment.

    .DESCRIPTION
        Retrieves deployment tokens via the /v1/deployment_tokens and
        /v1/deployment_tokens/{id} endpoints. Lists newest first and includes
        tokens created by RMM integrations. Token values are masked to their
        first five characters; the full value is only returned by
        New-EvoDeploymentToken.

    .PARAMETER Id
        The ID of the deployment token to retrieve.

    .PARAMETER Page
        Page number for the results when listing deployment tokens.

    .PARAMETER Limit
        Number of items per page.

    .PARAMETER Query
        Optional search term applied to the token name.

    .PARAMETER Active
        Optional filter for active status: 'true' or 'false'.

    .PARAMETER TenantIdList
        Optional list of tenant IDs to filter tokens by.

    .PARAMETER DirectoryIdList
        Optional list of directory IDs to filter tokens by.

    .EXAMPLE
        Get-EvoDeploymentToken -TenantIdList 'TENANT_GUID' -Active 'true'

    .EXAMPLE
        Get-EvoDeploymentToken -Id 'DEPLOYMENT_TOKEN_GUID'
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('DeploymentTokenId')]
        [string]$Id,

        [Parameter(ParameterSetName = 'List')]
        [Nullable[int]]$Page,

        [Parameter(ParameterSetName = 'List')]
        [Nullable[int]]$Limit,

        [Parameter(ParameterSetName = 'List')]
        [Alias('Q')]
        [string]$Query,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('true','false')]
        [string]$Active,

        [Parameter(ParameterSetName = 'List')]
        [Alias('TenantIds')]
        [string[]]$TenantIdList,

        [Parameter(ParameterSetName = 'List')]
        [Alias('DirectoryIds')]
        [string[]]$DirectoryIdList
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $response = Invoke-EvoApiRequest -Method 'GET' -Path "/v1/deployment_tokens/$Id"

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                $token = $response.data
                if ($token -is [pscustomobject]) {
                    $token.PSObject.TypeNames.Insert(0, 'Evo.DeploymentToken')
                }
                return $token
            }

            return $response
        }

        $currentPage = if ($null -ne $Page) { $Page } else { 1 }
        $pageSize = if ($null -ne $Limit) { $Limit } else { $script:EvoPartnerApiConfig.DefaultPageSize }

        if ($pageSize -le 0) {
            throw 'Limit must be greater than zero.'
        }

        $queryParams = @{
            page  = $currentPage
            limit = $pageSize
        }

        if ($Query) {
            $queryParams['q'] = $Query
        }

        if ($Active) {
            $queryParams['active'] = $Active
        }

        if ($TenantIdList) {
            $queryParams['tenantIds[]'] = $TenantIdList
        }

        if ($DirectoryIdList) {
            $queryParams['directoryIds[]'] = $DirectoryIdList
        }

        $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/deployment_tokens' -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($token in $response.data) {
                if ($token -is [pscustomobject]) {
                    $token.PSObject.TypeNames.Insert(0, 'Evo.DeploymentToken')
                }
                Write-Output $token
            }
        }
        else {
            Write-Output $response
        }
    }
}
