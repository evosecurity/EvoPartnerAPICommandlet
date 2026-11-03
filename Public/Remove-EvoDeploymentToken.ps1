function Remove-EvoDeploymentToken {
    <#
    .SYNOPSIS
        Delete a deployment token by ID.

    .DESCRIPTION
        Permanently deletes a deployment token via the /v1/deployment_tokens/{id}
        DELETE endpoint. Endpoints already installed with it stay enrolled; the
        token can no longer enroll new ones. To keep the token but stop it
        working, use Set-EvoDeploymentToken -Active $false instead.

    .PARAMETER Id
        The ID of the deployment token to delete.

    .EXAMPLE
        Remove-EvoDeploymentToken -Id 'DEPLOYMENT_TOKEN_GUID' -Confirm:$false
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('DeploymentTokenId')]
        [string]$Id
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Deployment token $Id", 'Delete')) {
            return
        }

        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path "/v1/deployment_tokens/$Id"
        Write-Output $response
    }
}
