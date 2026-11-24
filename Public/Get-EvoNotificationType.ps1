function Get-EvoNotificationType {
    <#
    .SYNOPSIS
        List the notification types whose delivery rules can be configured.

    .DESCRIPTION
        Retrieves the notification types configurable in the current
        environment via the /v1/notification-types endpoint, with the
        delivery channels each one allows. Use -All to automatically
        iterate through all pages.

        Requires an API key with the Manage Notification Configuration
        permission.

    .PARAMETER Page
        Page number to retrieve.

    .PARAMETER Limit
        Maximum number of notification types per page (API maximum 100).
        Defaults to the module configuration's DefaultPageSize.

    .PARAMETER All
        When specified, automatically pages through all available result
        pages and streams notification types to the pipeline.

    .EXAMPLE
        Get-EvoNotificationType -All

        Returns every configurable notification type.

    .EXAMPLE
        Get-EvoNotificationType -All | Get-EvoNotificationTypeRule

        Returns the delivery rules of every configurable notification type.
    #>
    [CmdletBinding()]
    param(
        [int]$Page,

        [int]$Limit,

        [switch]$All
    )

    process {
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

            $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/notification-types' -Query $queryParams

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                foreach ($notificationType in $response.data) {
                    if ($notificationType -is [pscustomobject]) {
                        $notificationType.PSObject.TypeNames.Insert(0, 'Evo.NotificationType')
                    }
                    Write-Output $notificationType
                }
            }
            else {
                Write-Output $response
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
