function Get-EvoLicense {
    <#
    .SYNOPSIS
        Get Evo licenses.

    .DESCRIPTION
        Retrieves licenses from the Evo Partner API. When called with
        -Id, returns a single global license. When called without -Id,
        returns a paginated list of licenses.

    .PARAMETER Id
        The ID of the license to retrieve.

    .PARAMETER Page
        Page number for paginated queries when listing licenses.

    .PARAMETER Limit
        Maximum number of licenses per page. Defaults to the module
        configuration's DefaultPageSize.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('LicenseId')]
        [string]$Id,

        [Parameter(ParameterSetName = 'List')]
        [int]$Page,

        [Parameter(ParameterSetName = 'List')]
        [int]$Limit
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $path = "/v1/licenses/$Id"
            $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                $license = $response.data
                if ($license -is [pscustomobject]) {
                    $license.PSObject.TypeNames.Insert(0, 'Evo.License')
                }
                return $license
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

        $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/licenses' -Query $queryParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($license in $response.data) {
                if ($license -is [pscustomobject]) {
                    $license.PSObject.TypeNames.Insert(0, 'Evo.License')
                }
                Write-Output $license
            }
        }
        else {
            Write-Output $response
        }
    }
}
