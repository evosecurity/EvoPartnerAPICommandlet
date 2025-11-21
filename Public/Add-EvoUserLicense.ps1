function Add-EvoUserLicense {
    <#
    .SYNOPSIS
        Assign licenses to a user.

    .DESCRIPTION
        Calls the /v1/users/{id}/licenses POST endpoint to assign one or
        more licenses to the specified user. Returns the full API
        response including any failedItems.

    .PARAMETER UserId
        The ID of the user.

    .PARAMETER LicenseIdList
        One or more license IDs to assign to the user.
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
        if (-not $PSCmdlet.ShouldProcess("User $UserId", 'Add licenses')) {
            return
        }

        $body = @{
            licenseIds = $LicenseIdList
        }

        $path = "/v1/users/$UserId/licenses"
        $response = Invoke-EvoApiRequest -Method 'POST' -Path $path -Body $body
        Write-Output $response
    }
}
