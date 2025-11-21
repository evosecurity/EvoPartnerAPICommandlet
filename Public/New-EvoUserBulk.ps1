function New-EvoUserBulk {
    <#
    .SYNOPSIS
        Bulk create Evo users.

    .DESCRIPTION
        Creates multiple users in a single request via the
        /v1/users/bulk endpoint. Accepts user definitions from the
        pipeline and sends them as the `users` array required by the
        API. Returns the full API response including created users,
        license assignment results, and failed items.

    .PARAMETER User
        One or more user definition objects. Each object should contain
        at least Email, FirstName, LastName, IsAdmin, and DirectoryId
        properties. Optional properties include RoleGroupIds,
        LicenseIds, and SendWelcomeEmail.

    .EXAMPLE
        Import-Csv users.csv | New-EvoUserBulk

        Creates users based on the data in users.csv.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [psobject]$User
    )

    begin {
        $buffer = New-Object System.Collections.Generic.List[object]
    }

    process {
        if ($null -ne $User) {
            $buffer.Add($User)
        }
    }

    end {
        if ($buffer.Count -eq 0) {
            return
        }

        if (-not $PSCmdlet.ShouldProcess("$($buffer.Count) users", 'Bulk create')) {
            return
        }

        $usersPayload = @()
        foreach ($u in $buffer) {
            $item = @{
                email       = $u.Email
                firstName   = $u.FirstName
                lastName    = $u.LastName
                isAdmin     = $u.IsAdmin
                directoryId = $u.DirectoryId
            }

            if ($u.PSObject.Properties['RoleGroupIds'] -and $u.RoleGroupIds) {
                $item['roleGroupIds'] = @($u.RoleGroupIds)
            }

            if ($u.PSObject.Properties['LicenseIds'] -and $u.LicenseIds) {
                $item['licenseIds'] = @($u.LicenseIds)
            }

            if ($u.PSObject.Properties['SendWelcomeEmail']) {
                $item['sendWelcomeEmail'] = [bool]$u.SendWelcomeEmail
            }

            $usersPayload += $item
        }

        $body = @{
            users = $usersPayload
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/users/bulk' -Body $body
        Write-Output $response
    }
}
