function Get-EvoAsyncOperation {
    <#
    .SYNOPSIS
        Get an async operation by ID.

    .DESCRIPTION
        Retrieves the status and details of an async operation via the
        /v1/async_operations/{id} endpoint.

    .PARAMETER Id
        The ID of the async operation to retrieve.

    .EXAMPLE
        Get-EvoAsyncOperation -Id "12345678-1234-1234-1234-123456789012"

    .EXAMPLE
        $result = Remove-EvoDirectory -Id $directoryId
        Get-EvoAsyncOperation -Id $result.operationId
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('OperationId')]
        [string]$Id
    )

    process {
        $path = "/v1/async_operations/$Id"
        $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

        if ($response.data) {
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
