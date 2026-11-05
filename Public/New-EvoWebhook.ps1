function New-EvoWebhook {
    <#
    .SYNOPSIS
        Register a webhook subscription for event notifications.

    .DESCRIPTION
        Registers a callback URL via the /v1/webhook_subscriptions endpoint. The URL must be
        a publicly reachable HTTPS URL on port 443. A signing secret is returned
        once at registration and cannot be retrieved again. Store the secret
        securely to verify the X-Evo-Signature-V2 header on deliveries.

        Requires an API key with canManageWebhook, or canManageHelpDeskVerification
        for subscriptions to hdv.* events only.

        A maximum of 20 webhook endpoints may be registered per environment.

    .PARAMETER Url
        Publicly reachable HTTPS callback URL (port 443, no embedded credentials).

    .PARAMETER Events
        One or more event types to subscribe to:
        hdv.challenge_sent, hdv.confirmed, hdv.denied, hdv.expired,
        hdv.code_matched, hdv.code_mismatch, elevation_request.created,
        elevation_request.resolved, elevation_request.cancelled.
        The elevation_request.* events require canManageWebhook.

    .EXAMPLE
        New-EvoWebhook -Url 'https://partner.example.com/webhooks/hdv' -Events 'hdv.challenge_sent','hdv.confirmed','hdv.denied','hdv.expired'

        Registers a webhook for reverse and forward HDV lifecycle events.
        Save the returned secret; it is only returned once.

    .EXAMPLE
        New-EvoWebhook -Url 'https://partner.example.com/webhooks/eue' -Events 'elevation_request.created','elevation_request.resolved'

        Gets notified when an elevation request needs a decision and when it is resolved.
        Approve or deny it with Approve-EvoElevationRequest / Deny-EvoElevationRequest using
        the elevationRequestId and tenantId from the payload.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Url,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet(
            'hdv.challenge_sent',
            'hdv.confirmed',
            'hdv.denied',
            'hdv.expired',
            'hdv.code_matched',
            'hdv.code_mismatch',
            'elevation_request.created',
            'elevation_request.resolved',
            'elevation_request.cancelled'
        )]
        [string[]]$Events
    )

    process {
        if (-not $PSCmdlet.ShouldProcess($Url, 'Register webhook endpoint')) {
            return
        }

        $body = @{
            url    = $Url
            events = @($Events)
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/webhook_subscriptions' -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $webhook = $response.data
            if ($webhook -is [pscustomobject]) {
                $webhook.PSObject.TypeNames.Insert(0, 'Evo.Webhook')
            }
            Write-Output $webhook
        }
        else {
            Write-Output $response
        }
    }
}
