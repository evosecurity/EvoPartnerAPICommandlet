function Send-EvoUserWelcomeEmail {
    <#
    .SYNOPSIS
        Send welcome emails to one or more users.

    .DESCRIPTION
        Queues welcome emails for users via the /v1/users/welcome_emails
        endpoint. Accepts user IDs from the pipeline and sends them as
        the userIds array required by the API.

    .PARAMETER UserIdList
        One or more user IDs to send welcome emails to.
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

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) users", 'Send welcome emails')) {
            return
        }

        $body = @{
            userIds = $buffer.ToArray()
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/users/welcome_emails' -Body $body
        Write-Output $response
    }
}
