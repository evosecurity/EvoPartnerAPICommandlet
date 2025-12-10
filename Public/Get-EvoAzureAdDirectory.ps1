function Get-EvoAzureAdDirectory {
    <#
    .SYNOPSIS
        Get Azure AD Directories for the current environment.

    .DESCRIPTION
        Retrieves Azure AD Directories via the /v1/azure_directories endpoint.
        Can retrieve a single directory by ID or list directories with pagination.

    .PARAMETER Id
        Optional. The ID of a specific Azure AD Directory to retrieve.

    .PARAMETER Page
        Page number for the results.

    .PARAMETER Limit
        Number of items per page.

    .PARAMETER Query
        Optional search term applied to directory name or Azure tenant ID.

    .PARAMETER TenantIdList
        Optional list of tenant IDs to filter directories by.

    .EXAMPLE
        Get-EvoAzureAdDirectory

    .EXAMPLE
        Get-EvoAzureAdDirectory -Id "12345678-1234-1234-1234-123456789012"

    .EXAMPLE
        Get-EvoAzureAdDirectory -Query "contoso" -Limit 50
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('DirectoryId')]
        [string]$Id,

        [Parameter(ParameterSetName = 'List')]
        [Nullable[int]]$Page,

        [Parameter(ParameterSetName = 'List')]
        [Nullable[int]]$Limit,

        [Parameter(ParameterSetName = 'List')]
        [Alias('Q')]
        [string]$Query,

        [Parameter(ParameterSetName = 'List')]
        [string[]]$TenantIdList
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $path = "/v1/azure_directories/$Id"
            $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                $dir = $response.data

                if ($dir -is [pscustomobject]) {
                    $dir.PSObject.TypeNames.Insert(0, 'Evo.AzureAdDirectory')
                }

                Write-Output $dir
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

            if ($TenantIdList) {
                $queryParams['tenantIds[]'] = $TenantIdList
            }

            $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/azure_directories' -Query $queryParams

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                foreach ($dir in $response.data) {
                    if ($dir -is [pscustomobject]) {
                        $dir.PSObject.TypeNames.Insert(0, 'Evo.AzureAdDirectory')
                    }
                    Write-Output $dir
                }
            }
            else {
                Write-Output $response
            }
        }
    }
}
