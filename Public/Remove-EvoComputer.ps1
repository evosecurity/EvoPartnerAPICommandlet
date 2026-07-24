function Remove-EvoComputer {
    <#
    .SYNOPSIS
        Delete a computer (endpoint) from the environment.

    .DESCRIPTION
        Deletes a computer via the /v1/computers/{id} endpoint.
        This operation is asynchronous and returns an operation ID.

        When -RemoveSoftware is specified, the request body includes
        removeSoftware so Partner API can remove software if the computer
        is RMM-managed. When omitted, the API defaults removeSoftware to false.

    .PARAMETER Id
        The ID of the computer to delete.

    .PARAMETER RemoveSoftware
        When specified, asks Partner API to remove software from the computer
        if it is RMM-managed.

    .EXAMPLE
        Remove-EvoComputer -Id '00000000-0000-0000-0000-000000000000'

        Deletes the computer with the specified ID.

    .EXAMPLE
        Remove-EvoComputer -Id '00000000-0000-0000-0000-000000000000' -RemoveSoftware

        Deletes the computer and requests software removal if RMM-managed.

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
        [string]$Id,

        [Parameter()]
        [switch]$RemoveSoftware
    )

    process {
        $action = if ($RemoveSoftware) { 'Delete (remove software)' } else { 'Delete' }
        if (-not $PSCmdlet.ShouldProcess("Computer $Id", $action)) {
            return
        }

        $path = "/v1/computers/$Id"
        $invokeParams = @{
            Method = 'DELETE'
            Path   = $path
        }

        if ($PSBoundParameters.ContainsKey('RemoveSoftware')) {
            $invokeParams['Body'] = @{
                removeSoftware = [bool]$RemoveSoftware
            }
        }

        $response = Invoke-EvoApiRequest @invokeParams

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            Write-Output $response.data
        }
        else {
            Write-Output $response
        }
    }
}
