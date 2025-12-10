function New-EvoAzureAdDirectory {
    <#
    .SYNOPSIS
        Initiate Azure AD Directory creation flow.

    .DESCRIPTION
        Initiates the Azure AD Directory creation flow via the /v1/azure_directories endpoint.
        Returns a redirect URL that should be used to complete the OAuth authentication.

    .PARAMETER EvoTenantId
        The Evo tenant ID to associate the directory with.

    .PARAMETER Name
        The name for the Azure AD directory.

    .PARAMETER AzurePrimaryDomainNameOrAzureTenantId
        The Azure primary domain name or Azure tenant ID.

    .PARAMETER SyncPasswordsFromEvoToAzure
        Whether to sync passwords from Evo to Azure. Default is false.

    .PARAMETER AutoAssignTechnicianElevationLicenses
        Whether to auto-assign technician elevation licenses. Default is false.

    .PARAMETER AutoAssignMfaAndSsoLicenses
        Whether to auto-assign MFA and SSO licenses. Default is false.

    .PARAMETER AutoAssignHelpDeskVerificationLicenses
        Whether to auto-assign help desk verification licenses. Default is false.

    .PARAMETER AutoEnableMfa
        Whether to auto-enable MFA for users. Default is false.

    .PARAMETER AutoSendWelcomeEmails
        Whether to auto-send welcome emails to users. Default is false.

    .EXAMPLE
        New-EvoAzureAdDirectory -EvoTenantId "tenant-uuid" -Name "Contoso Azure AD" -AzurePrimaryDomainNameOrAzureTenantId "contoso.onmicrosoft.com"

    .EXAMPLE
        New-EvoAzureAdDirectory -EvoTenantId "tenant-uuid" -Name "Contoso" -AzurePrimaryDomainNameOrAzureTenantId "contoso.com" -AutoEnableMfa -AutoSendWelcomeEmails
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$EvoTenantId,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$AzurePrimaryDomainNameOrAzureTenantId,

        [Parameter()]
        [switch]$SyncPasswordsFromEvoToAzure,

        [Parameter()]
        [switch]$AutoAssignTechnicianElevationLicenses,

        [Parameter()]
        [switch]$AutoAssignMfaAndSsoLicenses,

        [Parameter()]
        [switch]$AutoAssignHelpDeskVerificationLicenses,

        [Parameter()]
        [switch]$AutoEnableMfa,

        [Parameter()]
        [switch]$AutoSendWelcomeEmails
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Azure AD Directory '$Name'", 'Create')) {
            return
        }

        $body = @{
            evoTenantId                           = $EvoTenantId
            name                                  = $Name
            azurePrimaryDomainNameOrAzureTenantId = $AzurePrimaryDomainNameOrAzureTenantId
            syncPasswordsFromEvoToAzure           = [bool]$SyncPasswordsFromEvoToAzure
            autoAssignTechnicianElevationLicenses = [bool]$AutoAssignTechnicianElevationLicenses
            autoAssignMfaAndSsoLicenses           = [bool]$AutoAssignMfaAndSsoLicenses
            autoAssignHelpDeskVerificationLicenses = [bool]$AutoAssignHelpDeskVerificationLicenses
            autoEnableMfa                         = [bool]$AutoEnableMfa
            autoSendWelcomeEmails                 = [bool]$AutoSendWelcomeEmails
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/azure_directories/initiate' -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $result = $response.data

            if ($result -is [pscustomobject]) {
                $result.PSObject.TypeNames.Insert(0, 'Evo.AzureAdDirectoryFlow')
            }

            Write-Output $result
        }
        else {
            Write-Output $response
        }
    }
}
