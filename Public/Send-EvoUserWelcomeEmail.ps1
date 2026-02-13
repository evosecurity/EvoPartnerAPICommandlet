function Send-EvoUserWelcomeEmail {
    <#
    .SYNOPSIS
        Send welcome emails to one or more users.

    .DESCRIPTION
        Queues welcome emails for users via the /v1/users/welcome_emails
        endpoint. Accepts user objects or IDs from the pipeline and sends
        them as the users array required by the API.

    .PARAMETER UserId
        User ID to send welcome email to.

    .PARAMETER WelcomeEmailAlternate
        Optional alternate email address to send the welcome email to instead
        of the user's primary email.

    .EXAMPLE
        Send-EvoUserWelcomeEmail -UserId 'user-id'

        Sends a welcome email to the user's primary email.

    .EXAMPLE
        Send-EvoUserWelcomeEmail -UserId 'user-id' -WelcomeEmailAlternate 'alternate@example.com'

        Sends a welcome email to an alternate email address.

    .EXAMPLE
        @(
            @{ UserId = 'user-id-1'; WelcomeEmailAlternate = 'alt1@example.com' },
            @{ UserId = 'user-id-2' }
        ) | Send-EvoUserWelcomeEmail

        Sends welcome emails to multiple users with optional alternate emails.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$UserId,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$WelcomeEmailAlternate
    )

    begin {
        $buffer = New-Object System.Collections.Generic.List[object]
    }

    process {
        if (-not [string]::IsNullOrWhiteSpace($UserId)) {
            $userObj = @{
                userId = $UserId
            }

            if (-not [string]::IsNullOrWhiteSpace($WelcomeEmailAlternate)) {
                $userObj['welcomeEmailAlternate'] = $WelcomeEmailAlternate
            }

            $buffer.Add($userObj)
        }
    }

    end {
        if ($buffer.Count -eq 0) {
            return
        }

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) users", 'Send welcome emails')) {
            return
        }

        $body = @{
            users = $buffer.ToArray()
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/users/welcome_emails' -Body $body
        Write-Output $response
    }
}
