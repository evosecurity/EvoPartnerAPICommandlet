function Remove-EvoDirectory {
    <#
    .SYNOPSIS
        Delete a Cloud Directory by ID.

    .DESCRIPTION
        Deletes a Cloud Directory via the /v1/directories/{id} endpoint.
        The deletion is processed asynchronously. Returns an async operation
        that can be tracked using Get-EvoAsyncOperation.

    .PARAMETER Id
        The ID of the Cloud Directory to delete.

    .EXAMPLE
        Remove-EvoDirectory -Id "12345678-1234-1234-1234-123456789012"

    .EXAMPLE
        Get-EvoDirectory | Where-Object { $_.name -eq "OldDirectory" } | Remove-EvoDirectory
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('DirectoryId')]
        [string]$Id
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Cloud Directory $Id", 'Delete')) {
            return
        }

        $path = "/v1/directories/$Id"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $operation = $response.data

            if ($operation -is [pscustomobject]) {
                $operation.PSObject.TypeNames.Insert(0, 'Evo.AsyncOperation')
            }

            Write-Output $operation
        }
        else {
            Write-Output $response
        }
    }
}
