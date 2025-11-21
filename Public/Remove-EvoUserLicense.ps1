function Remove-EvoUserLicense {
    <#
    .SYNOPSIS
        Remove licenses from a user.

    .DESCRIPTION
        Calls the /v1/users/{id}/licenses DELETE endpoint to remove one
        or more licenses from the specified user.

    .PARAMETER UserId
        The ID of the user.

    .PARAMETER LicenseIdList
        One or more license IDs to remove from the user.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$UserId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$LicenseIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("User $UserId", 'Remove licenses')) {
            return
        }

        $body = @{
            licenseIds = $LicenseIdList
        }

        $path = "/v1/users/$UserId/licenses"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path -Body $body
        Write-Output $response
    }
}
