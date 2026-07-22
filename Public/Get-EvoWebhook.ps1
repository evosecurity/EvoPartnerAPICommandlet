function Get-EvoWebhook {
    <#
    .SYNOPSIS
        List webhook endpoints for the current environment.

    .DESCRIPTION
        Retrieves all webhook endpoints registered via the /v1/webhooks endpoint.
        Signing secrets are never included in list responses.

    .EXAMPLE
        Get-EvoWebhook

        Returns all webhook endpoints for the current environment.
    #>
    [CmdletBinding()]
    param()

    process {
        $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/webhooks'

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($webhook in $response.data) {
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
