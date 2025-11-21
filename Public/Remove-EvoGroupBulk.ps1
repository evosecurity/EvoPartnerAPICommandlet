function Remove-EvoGroupBulk {
    <#
    .SYNOPSIS
        Bulk delete manual user groups.

    .DESCRIPTION
        Deactivates multiple groups via the /v1/groups/bulk DELETE
        endpoint.

    .PARAMETER GroupIdList
        One or more group IDs to delete.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$GroupIdList
    )

    begin {
        $buffer = New-Object System.Collections.Generic.List[string]
    }

    process {
        foreach ($id in $GroupIdList) {
            if (-not [string]::IsNullOrWhiteSpace($id)) {
                $buffer.Add($id)
            }
        }
    }

    end {
        if ($buffer.Count -eq 0) {
            return
        }

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) groups", 'Bulk delete')) {
            return
        }

        $body = @{
            groupIds = $buffer.ToArray()
        }

        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path '/v1/groups/bulk' -Body $body
        Write-Output $response
    }
}
