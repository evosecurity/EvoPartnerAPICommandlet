function Get-EvoHelpDeskVerification {
    <#
    .SYNOPSIS
        Get Help Desk Verification requests.

    .DESCRIPTION
        Retrieves one or more HDV requests from the Evo Partner API. When called
        with -Id, it returns a single HDV request. When called without -Id, it
        lists HDV requests with optional filters and paging or returns all HDV
        requests when -All is specified.

    .PARAMETER Id
        The ID of the HDV request to retrieve.

    .PARAMETER Page
        Page number for paginated queries when listing HDV requests.

    .PARAMETER Limit
        Maximum number of HDV requests per page. Defaults to the module
        configuration's DefaultPageSize.

    .PARAMETER Status
        Filter by HDV status: pending, verified, failed, expired, or cancelled.

    .PARAMETER UserIdList
        Filter by one or more user IDs.

    .PARAMETER Method
        Filter by verification method: mobile, sms, email, or ms.

    .PARAMETER All
        When specified, automatically pages through all available
        result pages and streams HDV requests to the pipeline.

    .EXAMPLE
        Get-EvoHelpDeskVerification -Id '00000000-0000-0000-0000-000000000000'

        Returns the HDV request with the specified ID.

    .EXAMPLE
        Get-EvoHelpDeskVerification -All

        Returns all HDV requests in the current environment.

    .EXAMPLE
        Get-EvoHelpDeskVerification -Status pending -Method email

        Returns all pending email HDV requests.

    .EXAMPLE
        Get-EvoHelpDeskVerification -UserIdList 'user-id-1', 'user-id-2'

        Returns HDV requests for specific users.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('HdvId')]
        [string]$Id,

        [Parameter(ParameterSetName = 'List')]
        [int]$Page,

        [Parameter(ParameterSetName = 'List')]
        [int]$Limit,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('pending', 'verified', 'failed', 'expired', 'cancelled')]
        [string]$Status,

        [Parameter(ParameterSetName = 'List')]
        [string[]]$UserIdList,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('mobile', 'sms', 'email', 'ms')]
        [string]$Method,

        [Parameter(ParameterSetName = 'List')]
        [switch]$All
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $path = "/v1/help_desk_verifications/$Id"
            $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                $hdv = $response.data
                if ($hdv -is [pscustomobject]) {
                    $hdv.PSObject.TypeNames.Insert(0, 'Evo.HelpDeskVerification')
                }
                return $hdv
            }

            return $response
        }

        $currentPage = if ($PSBoundParameters.ContainsKey('Page')) { $Page } else { 1 }
        $pageSize = if ($PSBoundParameters.ContainsKey('Limit')) { $Limit } else { $script:EvoPartnerApiConfig.DefaultPageSize }

        if ($pageSize -le 0) {
            throw 'Limit must be greater than zero.'
        }

        do {
            $queryParams = @{
                page  = $currentPage
                limit = $pageSize
            }

            if ($PSBoundParameters.ContainsKey('Status') -and $Status) {
                $queryParams['status'] = $Status
            }

            if ($PSBoundParameters.ContainsKey('Method') -and $Method) {
                $queryParams['method'] = $Method
            }

            if ($UserIdList -and $UserIdList.Count -gt 0) {
                $queryParams['userIds[]'] = $UserIdList
            }

            $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/help_desk_verifications' -Query $queryParams

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                foreach ($hdv in $response.data) {
                    if ($hdv -is [pscustomobject]) {
                        $hdv.PSObject.TypeNames.Insert(0, 'Evo.HelpDeskVerification')
                    }
                    Write-Output $hdv
                }
            }

            $hasMore = $false
            if ($All.IsPresent -and $response -and $response.PSObject.Properties['pagination']) {
                $pagination = $response.pagination
                if ($pagination -and $pagination.page -lt $pagination.totalPages) {
                    $currentPage = [int]$pagination.page + 1
                    $hasMore = $true
                }
            }
        }
        while ($hasMore)
    }
}
