function Get-EvoEnvironmentLicense {
    <#
    .SYNOPSIS
        Get environment licenses for the current environment.

    .DESCRIPTION
        Retrieves purchased licenses for the current environment via
        /v1/environment_licenses and /v1/environment_licenses/{id}.

    .PARAMETER Id
        Optional environment license ID to retrieve.

    .PARAMETER Page
        Page number when listing environment licenses.

    .PARAMETER Limit
        Number of items per page.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('EnvironmentLicenseId')]
        [string]$Id,

        [Parameter(ParameterSetName = 'List')]
        [int]$Page,

        [Parameter(ParameterSetName = 'List')]
        [int]$Limit
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $path = "/v1/environment_licenses/$Id"
            $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                $lic = $response.data
                if ($lic -is [pscustomobject]) {
                    $lic.PSObject.TypeNames.Insert(0, 'Evo.EnvironmentLicense')
                }
                return $lic
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

        $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/environment_licenses' -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($lic in $response.data) {
                if ($lic -is [pscustomobject]) {
                    $lic.PSObject.TypeNames.Insert(0, 'Evo.EnvironmentLicense')
                }
                Write-Output $lic
            }
        }
        else {
            Write-Output $response
        }
    }
}
