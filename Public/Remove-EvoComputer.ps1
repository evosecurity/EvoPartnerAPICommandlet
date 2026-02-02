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
        Write-Output $response
    }
}
