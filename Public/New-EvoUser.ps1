function New-EvoUser {
    <#
    .SYNOPSIS
        Create a new Evo user in the current environment.

    .DESCRIPTION
        Creates a new user via the Evo Partner API /v1/users endpoint.
        Returns the created user object. License assignment results, when
        present, are attached to the user as a LicenseAssignments
        property.

    .PARAMETER Email
        The email address of the user to create.

    .PARAMETER FirstName
        The first name of the user.

    .PARAMETER LastName
        The last name of the user.

    .PARAMETER IsAdmin
        Indicates whether the user is an admin.

    .PARAMETER DirectoryId
        The Cloud Directory ID to assign to this user.

    .PARAMETER LicenseIdList
        Optional list of license IDs to assign to the user.

    .PARAMETER RoleGroupIdList
        Optional list of role group IDs to assign to the user.

    .PARAMETER SendWelcomeEmail
        When specified, sends a welcome email to the created user.

    .EXAMPLE
        New-EvoUser -Email 'user@example.com' -FirstName 'Test' -LastName 'User' -IsAdmin $true -DirectoryId '00000000-0000-0000-0000-000000000000'

        Creates a new admin user in the specified Cloud Directory.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Email,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$FirstName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$LastName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [bool]$IsAdmin,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$DirectoryId,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]$LicenseIdList,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]$RoleGroupIdList,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]$SendWelcomeEmail
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("User $Email", 'Create')) {
            return
        }

        $body = @{
            email       = $Email
            firstName   = $FirstName
            lastName    = $LastName
            isAdmin     = $IsAdmin
            directoryId = $DirectoryId
        }

        if ($LicenseIdList) {
            $body['licenseIds'] = $LicenseIdList
        }

        if ($RoleGroupIdList) {
            $body['roleGroupIds'] = $RoleGroupIdList
        }

        if ($PSBoundParameters.ContainsKey('SendWelcomeEmail')) {
            $body['sendWelcomeEmail'] = [bool]$SendWelcomeEmail
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/users' -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data'] -and $response.data.PSObject.Properties['user']) {
            $user = $response.data.user

            if ($response.data.PSObject.Properties['licenseAssignments']) {
                $user | Add-Member -NotePropertyName 'LicenseAssignments' -NotePropertyValue $response.data.licenseAssignments -Force
            }

            if ($user -is [pscustomobject]) {
                $user.PSObject.TypeNames.Insert(0, 'Evo.User')
            }

            Write-Output $user
        }
        else {
            Write-Output $response
        }
    }
}
