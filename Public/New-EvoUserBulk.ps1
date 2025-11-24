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

        function ConvertTo-EvoBooleanFromCsv {
            param(
                [Parameter(Mandatory = $false)]
                [object]$Value
            )

            if ($null -eq $Value) {
                return $false
            }

            if ($Value -is [bool]) {
                return $Value
            }

            if ($Value -is [int] -or $Value -is [long]) {
                return [bool]([int]$Value)
            }

            $s = $Value.ToString().Trim().ToLowerInvariant()

            if ($s -eq '') {
                return $false
            }

            switch ($s) {
                'true'  { return $true }
                '1'     { return $true }
                'yes'   { return $true }
                'y'     { return $true }
                'false' { return $false }
                '0'     { return $false }
                'no'    { return $false }
                'n'     { return $false }
                default { return $false }
            }
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
                isAdmin     = ConvertTo-EvoBooleanFromCsv -Value $u.IsAdmin
                directoryId = $u.DirectoryId
            }

            if ($u.PSObject.Properties['RoleGroupIds'] -and $u.RoleGroupIds) {
                $item['roleGroupIds'] = @($u.RoleGroupIds)
            }

            if ($u.PSObject.Properties['LicenseIds'] -and $u.LicenseIds) {
                $item['licenseIds'] = @($u.LicenseIds)
            }

            if ($u.PSObject.Properties['SendWelcomeEmail']) {
                $item['sendWelcomeEmail'] = ConvertTo-EvoBooleanFromCsv -Value $u.SendWelcomeEmail
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
