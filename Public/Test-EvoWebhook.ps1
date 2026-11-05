function Test-EvoWebhook {
    <#
    .SYNOPSIS
        Send a test (ping) delivery to a webhook subscription.

    .DESCRIPTION
        Calls the /v1/webhook_subscriptions/{id}/ping endpoint, which immediately POSTs a
        signed "ping" event to the subscription's URL and returns the delivery record.
        Works on disabled subscriptions. A ping is never retried.

    .PARAMETER Id
        The ID of the webhook subscription to ping.

    .EXAMPLE
        Test-EvoWebhook -Id '00000000-0000-0000-0000-000000000000'

        Pings the subscription. Check status and responseStatus on the result.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('WebhookId')]
        [string]$Id
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Webhook $Id", 'Send ping')) {
            return
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path "/v1/webhook_subscriptions/$Id/ping"

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $delivery = $response.data
            if ($delivery -is [pscustomobject]) {
                $delivery.PSObject.TypeNames.Insert(0, 'Evo.WebhookDelivery')
            }
            Write-Output $delivery
        }
        else {
            Write-Output $response
        }
    }
}
