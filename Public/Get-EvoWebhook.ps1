function Get-EvoWebhook {
    <#
    .SYNOPSIS
        List webhook subscriptions, or get one by ID.

    .DESCRIPTION
        Retrieves webhook subscriptions via the /v1/webhook_subscriptions endpoint.
        Signing secrets are never included in responses.

    .PARAMETER Id
        The ID of a single webhook subscription to retrieve.

    .EXAMPLE
        Get-EvoWebhook

        Returns all webhook subscriptions for the current environment.

    .EXAMPLE
        Get-EvoWebhook -Id '00000000-0000-0000-0000-000000000000'

        Returns one webhook subscription.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('WebhookId')]
        [string]$Id
    )

    process {
        $path = if ($PSCmdlet.ParameterSetName -eq 'ById') { "/v1/webhook_subscriptions/$Id" } else { '/v1/webhook_subscriptions' }
        $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($webhook in @($response.data)) {
                if ($webhook -is [pscustomobject]) {
                    $webhook.PSObject.TypeNames.Insert(0, 'Evo.Webhook')
                }
                Write-Output $webhook
            }
        }
        else {
            Write-Output $response
        }
    }
}
