function Get-EvoWebhookDelivery {
    <#
    .SYNOPSIS
        List a webhook subscription's delivery log.

    .DESCRIPTION
        Retrieves deliveries from the /v1/webhook_subscriptions/{id}/deliveries endpoint,
        newest first. Deliveries are kept for 30 days.

    .PARAMETER WebhookId
        The ID of the webhook subscription.

    .PARAMETER Status
        Only return deliveries in this status: pending, succeeded or failed.

    .PARAMETER Event
        Only return deliveries of this event type (for example hdv.confirmed or ping).

    .PARAMETER Page
        Page number to retrieve (default 1).

    .PARAMETER Limit
        Number of deliveries per page (defaults to the configured page size).

    .PARAMETER All
        Retrieve every page.

    .EXAMPLE
        Get-EvoWebhookDelivery -WebhookId '00000000-0000-0000-0000-000000000000' -Status failed -All

        Returns every failed delivery for the subscription.

    .EXAMPLE
        Get-EvoWebhook | Get-EvoWebhookDelivery -Limit 5

        Returns the five most recent deliveries for each subscription.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$WebhookId,

        [Parameter()]
        [ValidateSet('pending', 'succeeded', 'failed')]
        [string]$Status,

        [Parameter()]
        [string]$Event,

        [Parameter()]
        [Nullable[int]]$Page,

        [Parameter()]
        [Nullable[int]]$Limit,

        [Parameter()]
        [switch]$All
    )

    process {
        $currentPage = if ($PSBoundParameters.ContainsKey('Page') -and $null -ne $Page) { $Page } else { 1 }
        $pageSize = if ($PSBoundParameters.ContainsKey('Limit') -and $null -ne $Limit) { $Limit } else { $script:EvoPartnerApiConfig.DefaultPageSize }

        if ($pageSize -le 0) {
            throw 'Limit must be greater than zero.'
        }

        do {
            $queryParams = @{
                page  = $currentPage
                limit = $pageSize
            }
            if ($PSBoundParameters.ContainsKey('Status') -and $Status) { $queryParams['status'] = $Status }
            if ($PSBoundParameters.ContainsKey('Event') -and $Event) { $queryParams['event'] = $Event }

            $response = Invoke-EvoApiRequest -Method 'GET' -Path "/v1/webhook_subscriptions/$WebhookId/deliveries" -Query $queryParams

            if ($null -ne $response -and $response.PSObject.Properties['data']) {
                foreach ($delivery in $response.data) {
                    if ($delivery -is [pscustomobject]) {
                        $delivery.PSObject.TypeNames.Insert(0, 'Evo.WebhookDelivery')
                    }
                    Write-Output $delivery
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
