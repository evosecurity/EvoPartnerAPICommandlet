function Set-EvoWebhook {
    <#
    .SYNOPSIS
        Enable or disable a webhook endpoint.

    .DESCRIPTION
        Updates a webhook endpoint via the /v1/webhooks/{id} PATCH endpoint.
        Disabled endpoints are retained but receive no events until re-enabled.

    .PARAMETER Id
        The ID of the webhook endpoint to update.

    .PARAMETER Enabled
        Whether deliveries to this endpoint are active.

    .EXAMPLE
        Set-EvoWebhook -Id '00000000-0000-0000-0000-000000000000' -Enabled $false

        Disables deliveries to the specified webhook endpoint.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('WebhookId')]
        [string]$Id,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [bool]$Enabled
    )

    process {
        $action = if ($Enabled) { 'Enable' } else { 'Disable' }
        if (-not $PSCmdlet.ShouldProcess("Webhook $Id", $action)) {
            return
        }

        $body = @{
            enabled = $Enabled
        }

        $path = "/v1/webhooks/$Id"
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
