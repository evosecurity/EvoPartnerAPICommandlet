function Remove-EvoAccessToken {
    <#
    .SYNOPSIS
        Delete an access token by ID.

    .DESCRIPTION
        Deletes an access token via the /v1/access_tokens/{id} DELETE
        endpoint.

    .PARAMETER Id
        The ID of the token to delete.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('AccessTokenId')]
        [string]$Id
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Access token $Id", 'Delete')) {
            return
        }

        $path = "/v1/access_tokens/$Id"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path
        Write-Output $response
    }
}
