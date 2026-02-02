function Confirm-EvoHelpDeskVerificationEmail {
    <#
    .SYNOPSIS
        Verify an email Help Desk Verification request.

    .DESCRIPTION
        Verifies an email HDV request via the /v1/help_desk_verifications/email/{id}/verify endpoint.

    .PARAMETER Id
        The ID of the HDV request to verify.

    .PARAMETER Code
        The verification code provided by the user.

    .EXAMPLE
        Confirm-EvoHelpDeskVerificationEmail -Id 'hdv-id' -Code '123456'

        Verifies the email HDV request with the provided code.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('HdvId')]
        [string]$Id,

        [Parameter(Mandatory = $true)]
        [string]$Code
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("HDV $Id", "Verify email with code")) {
            return
        }

        $body = @{
            code = $Code
        }

        $path = "/v1/help_desk_verifications/email/$Id/verify"
        $response = Invoke-EvoApiRequest -Method 'PATCH' -Path $path -Body $body
        Write-Output $response
    }
}
