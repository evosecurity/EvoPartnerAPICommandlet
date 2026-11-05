function Remove-EvoWebhook {
    <#
    .SYNOPSIS
        Delete a webhook endpoint by ID.

    .DESCRIPTION
        Deletes a webhook endpoint via the /v1/webhook_subscriptions/{id} DELETE endpoint.

    .PARAMETER Id
        The ID of the webhook endpoint to delete.

    .EXAMPLE
        Remove-EvoWebhook -Id '00000000-0000-0000-0000-000000000000'

        Deletes the specified webhook endpoint.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('WebhookId')]
        [string]$Id
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Webhook $Id", 'Delete')) {
            return
        }

        $path = "/v1/webhook_subscriptions/$Id"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path
        Write-Output $response
    }
}
