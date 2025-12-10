function Set-EvoUser {
    <#
    .SYNOPSIS
        Update an existing Evo user.

    .DESCRIPTION
        Updates user properties via the Evo Partner API /v1/users/{id}
        endpoint. Only properties explicitly provided are sent to the
        API. Returns the updated user object.

    .PARAMETER Id
        The ID of the user to update.

    .PARAMETER FirstName
        The new first name of the user.

    .PARAMETER LastName
        The new last name of the user.

    .PARAMETER IsAdmin
        Updated admin status of the user.

    .PARAMETER DirectoryId
        Cloud Directory ID to associate with the user.

    .PARAMETER MfaEnabled
        Whether MFA is enabled for the user.

    .EXAMPLE
        Set-EvoUser -Id '00000000-0000-0000-0000-000000000000' -FirstName 'Updated'

        Updates the first name of the specified user.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('UserId')]
        [string]$Id,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$FirstName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$LastName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [bool]$IsAdmin,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$DirectoryId,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Nullable[bool]]$MfaEnabled
    )

    process {
        $body = @{}

        if ($PSBoundParameters.ContainsKey('FirstName')) {
            $body['firstName'] = $FirstName
        }

        if ($PSBoundParameters.ContainsKey('LastName')) {
            $body['lastName'] = $LastName
        }

        if ($PSBoundParameters.ContainsKey('IsAdmin')) {
            $body['isAdmin'] = $IsAdmin
        }

        if ($PSBoundParameters.ContainsKey('DirectoryId')) {
            $body['directoryId'] = $DirectoryId
        }

        if ($PSBoundParameters.ContainsKey('MfaEnabled')) {
            $body['mfaEnabled'] = $MfaEnabled
        }

        if ($body.Count -eq 0) {
            Write-Verbose 'No updatable fields were provided.'
            return
        }

        if (-not $PSCmdlet.ShouldProcess("User $Id", 'Update')) {
            return
        }

        $path = "/v1/users/$Id"
        $response = Invoke-EvoApiRequest -Method 'PUT' -Path $path -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $user = $response.data

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
