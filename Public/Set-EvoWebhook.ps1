function Set-EvoWebhook {
    <#
    .SYNOPSIS
        Update a webhook subscription's URL, events or enabled state.

    .DESCRIPTION
        Updates a webhook subscription via the /v1/webhook_subscriptions/{id} PATCH endpoint.
        Only the parameters you pass are changed. Disabled subscriptions are retained but
        receive no events until re-enabled, and their pending retries fail.

    .PARAMETER Id
        The ID of the webhook subscription to update.

    .PARAMETER Url
        New publicly reachable HTTPS callback URL (port 443, no embedded credentials).

    .PARAMETER Events
        Event types that replace the subscription's current list.

    .PARAMETER Enabled
        Whether deliveries to this subscription are active.

    .EXAMPLE
        Set-EvoWebhook -Id '00000000-0000-0000-0000-000000000000' -Enabled $false

        Disables deliveries to the specified webhook subscription.

    .EXAMPLE
        Set-EvoWebhook -Id '00000000-0000-0000-0000-000000000000' -Url 'https://partner.example.com/hooks/v2' -Events 'hdv.confirmed','hdv.denied'

        Moves the subscription to a new URL and replaces its events.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('WebhookId')]
        [string]$Id,

        [Parameter()]
        [string]$Url,

        [Parameter()]
        [ValidateSet(
            'hdv.challenge_sent',
            'hdv.confirmed',
            'hdv.denied',
            'hdv.expired',
            'hdv.code_matched',
            'hdv.code_mismatch'
        )]
        [string[]]$Events,

        [Parameter()]
        [bool]$Enabled
    )

    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('Url')) { $body['url'] = $Url }
        if ($PSBoundParameters.ContainsKey('Events')) { $body['events'] = @($Events) }
        if ($PSBoundParameters.ContainsKey('Enabled')) { $body['enabled'] = $Enabled }

        if ($body.Count -eq 0) {
            throw 'Specify at least one of -Url, -Events or -Enabled.'
        }

        if (-not $PSCmdlet.ShouldProcess("Webhook $Id", 'Update')) {
            return
        }

        $path = "/v1/webhook_subscriptions/$Id"
        $response = Invoke-EvoApiRequest -Method 'PATCH' -Path $path -Body $body

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
