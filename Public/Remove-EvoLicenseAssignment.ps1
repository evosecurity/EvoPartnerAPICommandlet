function Remove-EvoLicenseAssignment {
    <#
    .SYNOPSIS
        Remove a license from multiple users.

    .DESCRIPTION
        Calls the /v1/licenses/{id}/users DELETE endpoint to remove a
        specific license from multiple users.

    .PARAMETER LicenseId
        The ID of the license to remove.

    .PARAMETER UserIdList
        One or more user IDs to remove the license from.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$LicenseId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$UserIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("License $LicenseId", 'Remove from users')) {
            return
        }

        $body = @{
            userIds = $UserIdList
        }

        $path = "/v1/licenses/$LicenseId/users"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path -Body $body
        Write-Output $response
    }
}
