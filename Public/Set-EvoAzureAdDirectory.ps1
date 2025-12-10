function Set-EvoAzureAdDirectory {
    <#
    .SYNOPSIS
        Update an Azure AD Directory configuration.

    .DESCRIPTION
        Updates an Azure AD Directory configuration via the /v1/azure_directories/{id} endpoint.

    .PARAMETER Id
        The ID of the Azure AD Directory to update.

    .PARAMETER SyncPasswordsFromEvoToAzure
        Whether to sync passwords from Evo to Azure.

    .PARAMETER AutoAssignTechnicianElevationLicenses
        Whether to auto-assign technician elevation licenses.

    .PARAMETER AutoAssignMfaAndSsoLicenses
        Whether to auto-assign MFA and SSO licenses.

    .PARAMETER AutoAssignHelpDeskVerificationLicenses
        Whether to auto-assign help desk verification licenses.

    .PARAMETER AutoEnableMfa
        Whether to auto-enable MFA for users.

    .PARAMETER AutoSendWelcomeEmails
        Whether to auto-send welcome emails to users.

    .EXAMPLE
        Set-EvoAzureAdDirectory -Id "12345678-1234-1234-1234-123456789012" -AutoEnableMfa $true

    .EXAMPLE
        Get-EvoAzureAdDirectory -Id $dirId | Set-EvoAzureAdDirectory -AutoSendWelcomeEmails $true
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('DirectoryId')]
        [string]$Id,

        [Parameter()]
        [Nullable[bool]]$SyncPasswordsFromEvoToAzure,

        [Parameter()]
        [Nullable[bool]]$AutoAssignTechnicianElevationLicenses,

        [Parameter()]
        [Nullable[bool]]$AutoAssignMfaAndSsoLicenses,

        [Parameter()]
        [Nullable[bool]]$AutoAssignHelpDeskVerificationLicenses,

        [Parameter()]
        [Nullable[bool]]$AutoEnableMfa,

        [Parameter()]
        [Nullable[bool]]$AutoSendWelcomeEmails
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Azure AD Directory $Id", 'Update')) {
            return
        }

        $body = @{}

        if ($PSBoundParameters.ContainsKey('SyncPasswordsFromEvoToAzure')) {
            $body['syncPasswordsFromEvoToAzure'] = $SyncPasswordsFromEvoToAzure
        }
        if ($PSBoundParameters.ContainsKey('AutoAssignTechnicianElevationLicenses')) {
            $body['autoAssignTechnicianElevationLicenses'] = $AutoAssignTechnicianElevationLicenses
        }
        if ($PSBoundParameters.ContainsKey('AutoAssignMfaAndSsoLicenses')) {
            $body['autoAssignMfaAndSsoLicenses'] = $AutoAssignMfaAndSsoLicenses
        }
        if ($PSBoundParameters.ContainsKey('AutoAssignHelpDeskVerificationLicenses')) {
            $body['autoAssignHelpDeskVerificationLicenses'] = $AutoAssignHelpDeskVerificationLicenses
        }
        if ($PSBoundParameters.ContainsKey('AutoEnableMfa')) {
            $body['autoEnableMfa'] = $AutoEnableMfa
        }
        if ($PSBoundParameters.ContainsKey('AutoSendWelcomeEmails')) {
            $body['autoSendWelcomeEmails'] = $AutoSendWelcomeEmails
        }

        if ($body.Count -eq 0) {
            Write-Warning 'No update parameters specified.'
            return
        }

        $path = "/v1/azure_directories/$Id"
        $response = Invoke-EvoApiRequest -Method 'PUT' -Path $path -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $dir = $response.data

            if ($dir -is [pscustomobject]) {
                $dir.PSObject.TypeNames.Insert(0, 'Evo.AzureAdDirectory')
            }

            Write-Output $dir
        }
        else {
            Write-Output $response
        }
    }
}
