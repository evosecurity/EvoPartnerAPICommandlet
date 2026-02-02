function New-EvoHelpDeskVerification {
    <#
    .SYNOPSIS
        Create a new Help Desk Verification request.

    .DESCRIPTION
        Initiates a new HDV request via the /v1/users/{userId}/help_desk_verifications endpoint.
        This operation is asynchronous and returns an operation ID.

    .PARAMETER UserId
        The ID of the user to verify.

    .PARAMETER Method
        The verification method to use: mobile, sms, email, or ms.

    .PARAMETER RequesterId
        The ID of the user requesting the verification (help desk agent).

    .PARAMETER Origin
        Optional origin identifier for the request.

    .PARAMETER PsaTicketExternalId
        Optional PSA ticket external ID for tracking.

    .EXAMPLE
        New-EvoHelpDeskVerification -UserId 'user-id' -Method mobile -RequesterId 'requester-id'

        Creates a mobile HDV request for the specified user.

    .EXAMPLE
        New-EvoHelpDeskVerification -UserId 'user-id' -Method email -RequesterId 'requester-id' -PsaTicketExternalId 'CW-12345'

        Creates an email HDV request with PSA ticket tracking.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$UserId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('mobile', 'sms', 'email', 'ms')]
        [string]$Method,

        [Parameter(Mandatory = $true)]
        [string]$RequesterId,

        [Parameter()]
        [string]$Origin,

        [Parameter()]
        [string]$PsaTicketExternalId
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("User $UserId", "Create $Method HDV request")) {
            return
        }

        $body = @{
            method = $Method
            requesterId = $RequesterId
        }

        if ($PSBoundParameters.ContainsKey('Origin') -and $Origin) {
            $body['origin'] = $Origin
        }

        if ($PSBoundParameters.ContainsKey('PsaTicketExternalId') -and $PsaTicketExternalId) {
            $body['psaTicketExternalId'] = $PsaTicketExternalId
        }

        $path = "/v1/users/$UserId/help_desk_verifications"
        $response = Invoke-EvoApiRequest -Method 'POST' -Path $path -Body $body
        Write-Output $response
    }
}
