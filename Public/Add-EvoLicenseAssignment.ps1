function Add-EvoLicenseAssignment {
    <#
    .SYNOPSIS
        Assign a license to multiple users.

    .DESCRIPTION
        Calls the /v1/licenses/{id}/users POST endpoint to assign a
        specific license to multiple users.

    .PARAMETER LicenseId
        The ID of the license to assign.

    .PARAMETER UserIdList
        One or more user IDs to assign the license to.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$LicenseId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$UserIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("License $LicenseId", 'Assign to users')) {
            return
        }

        $body = @{
            userIds = $UserIdList
        }

        $path = "/v1/licenses/$LicenseId/users"
        $response = Invoke-EvoApiRequest -Method 'POST' -Path $path -Body $body
        Write-Output $response
    }
}
