function Confirm-EvoHelpDeskVerificationSms {
    <#
    .SYNOPSIS
        Verify an SMS Help Desk Verification request.

    .DESCRIPTION
        Verifies an SMS HDV request via the /v1/help_desk_verifications/sms/{id}/verify endpoint.

    .PARAMETER Id
        The ID of the HDV request to verify.

    .PARAMETER Code
        The verification code provided by the user.

    .EXAMPLE
        Confirm-EvoHelpDeskVerificationSms -Id 'hdv-id' -Code '654321'

        Verifies the SMS HDV request with the provided code.
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
        if (-not $PSCmdlet.ShouldProcess("HDV $Id", "Verify SMS with code")) {
            return
        }

        $body = @{
            code = $Code
        }

        $path = "/v1/help_desk_verifications/sms/$Id/verify"
        $response = Invoke-EvoApiRequest -Method 'PATCH' -Path $path -Body $body
        
        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            Write-Output $response.data
        }
        else {
            Write-Output $response
        }
    }
}
