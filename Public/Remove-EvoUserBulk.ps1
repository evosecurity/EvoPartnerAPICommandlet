function Remove-EvoUserBulk {
    <#
    .SYNOPSIS
        Bulk delete Evo users.

    .DESCRIPTION
        Deletes multiple users in a single request via the
        /v1/users/bulk DELETE endpoint. Returns success and any
        failedItems reported by the API.

    .PARAMETER UserIdList
        One or more user IDs to delete.

    .EXAMPLE
        Get-EvoUser -All | Select-Object -ExpandProperty id | Remove-EvoUserBulk
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$UserIdList
    )

    begin {
        $buffer = New-Object System.Collections.Generic.List[string]
    }

    process {
        foreach ($id in $UserIdList) {
            if (-not [string]::IsNullOrWhiteSpace($id)) {
                $buffer.Add($id)
            }
        }
    }

    end {
        if ($buffer.Count -eq 0) {
            return
        }

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) users", 'Bulk delete')) {
            return
        }

        $body = @{
            userIds = $buffer.ToArray()
        }

        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path '/v1/users/bulk' -Body $body
        Write-Output $response
    }
}
