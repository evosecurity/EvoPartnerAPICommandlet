function Remove-EvoComputer {
    <#
    .SYNOPSIS
        Delete a computer (endpoint) from the environment.

    .DESCRIPTION
        Deletes a computer via the /v1/computers/{id} endpoint.
        This operation is asynchronous and returns an operation ID.

    .PARAMETER Id
        The ID of the computer to delete.

    .EXAMPLE
        Remove-EvoComputer -Id '00000000-0000-0000-0000-000000000000'

        Deletes the computer with the specified ID.

    .EXAMPLE
        Get-EvoComputer -Query 'old-pc' | Remove-EvoComputer

        Deletes all computers matching the query.

    .EXAMPLE
        $result = Remove-EvoComputer -Id '00000000-0000-0000-0000-000000000000'
        Get-EvoAsyncOperation -Id $result.operationId

        Deletes a computer and uses the operationId to check the async operation
        status via the /v1/async_operations/{id} endpoint.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('ComputerId')]
        [string]$Id
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Computer $Id", 'Delete')) {
            return
        }

        $path = "/v1/computers/$Id"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path
        
        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            Write-Output $response.data
        }
        else {
            Write-Output $response
        }
    }
}
