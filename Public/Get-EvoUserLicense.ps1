function Get-EvoUserLicense {
    <#
    .SYNOPSIS
        Get licenses assigned to a specific user.

    .DESCRIPTION
        Retrieves licenses assigned to a user via the /v1/users/{id}/licenses
        endpoint.

    .PARAMETER UserId
        The ID of the user.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$UserId
    )

    process {
        $path = "/v1/users/$UserId/licenses"
        $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            foreach ($item in $response.data) {
                if ($item -is [pscustomobject]) {
                    $item.PSObject.TypeNames.Insert(0, 'Evo.License')
                }
                Write-Output $item
            }
        }
        else {
            Write-Output $response
        }
    }
}
