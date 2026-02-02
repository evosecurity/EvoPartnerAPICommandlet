function Get-EvoUserHdvMethods {
    <#
    .SYNOPSIS
        Get available Help Desk Verification methods for a user.

    .DESCRIPTION
        Retrieves the available HDV methods for a user via the
        /v1/users/{userId}/help_desk_verification_methods endpoint.

    .PARAMETER UserId
        The ID of the user to check HDV methods for.

    .EXAMPLE
        Get-EvoUserHdvMethods -UserId '00000000-0000-0000-0000-000000000000'

        Returns available HDV methods for the specified user.

    .EXAMPLE
        Get-EvoUser -Query 'john@example.com' | Get-EvoUserHdvMethods

        Gets HDV methods for a user found by email.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$UserId
    )

    process {
        $path = "/v1/users/$UserId/help_desk_verification_methods"
        $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $hdvMethods = $response.data
            if ($hdvMethods -is [pscustomobject]) {
                $hdvMethods.PSObject.TypeNames.Insert(0, 'Evo.HdvMethods')
            }
            return $hdvMethods
        }

        return $response
    }
}
