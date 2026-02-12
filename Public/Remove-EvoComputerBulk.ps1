function Remove-EvoComputerBulk {
    <#
    .SYNOPSIS
        Bulk delete computers (endpoints) from the environment.

    .DESCRIPTION
        Deletes multiple computers via the /v1/computers/bulk endpoint.
        This operation is asynchronous and returns operation details.

    .PARAMETER ComputerIdList
        One or more computer IDs to delete.

    .EXAMPLE
        Remove-EvoComputerBulk -ComputerIdList 'id1', 'id2', 'id3'

        Deletes multiple computers by their IDs.

    .EXAMPLE
        Get-EvoComputer -Os windows | Select-Object -First 10 | Remove-EvoComputerBulk

        Deletes the first 10 Windows computers.

    .EXAMPLE
        $result = Remove-EvoComputerBulk -ComputerIdList 'id1', 'id2', 'id3'
        Get-EvoAsyncOperation -Id $result.operationId

        Bulk deletes computers and uses the operationId to check the async operation
        status via the /v1/async_operations/{id} endpoint.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id', 'ComputerId')]
        [string[]]$ComputerIdList
    )

    begin {
        $buffer = New-Object System.Collections.Generic.List[string]
    }

    process {
        foreach ($id in $ComputerIdList) {
            if (-not [string]::IsNullOrWhiteSpace($id)) {
                $buffer.Add($id)
            }
        }
    }

    end {
        if ($buffer.Count -eq 0) {
            return
        }

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) computers", 'Bulk delete')) {
            return
        }

        $body = @{
            computerIds = $buffer.ToArray()
        }

        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path '/v1/computers/bulk' -Body $body
        
        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            Write-Output $response.data
        }
        else {
            Write-Output $response
        }
    }
}
