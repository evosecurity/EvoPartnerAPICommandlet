function New-EvoLdapDirectory {
    <#
    .SYNOPSIS
        Create a new LDAP (On-Prem Active Directory) Directory.

    .DESCRIPTION
        Creates a new LDAP Directory via the /v1/ldap_directories endpoint.
        The LDAP connection settings (host, port, credentials) are configured
        via the LDAP agent, not through this API.

    .PARAMETER TenantId
        The tenant ID to associate the directory with.

    .PARAMETER Name
        The name for the LDAP directory. Spaces will be replaced with underscores.

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
        New-EvoLdapDirectory -TenantId "tenant-uuid" -Name "Corp LDAP"

    .EXAMPLE
        New-EvoLdapDirectory -TenantId "tenant-uuid" -Name "Corp AD" -AutoEnableMfa -AutoSendWelcomeEmails
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$Name,

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
        if (-not $PSCmdlet.ShouldProcess("LDAP Directory '$Name'", 'Create')) {
            return
        }

        $body = @{
            tenantId                               = $TenantId
            name                                   = $Name
            autoAssignTechnicianElevationLicenses  = [bool]$AutoAssignTechnicianElevationLicenses
            autoAssignMfaAndSsoLicenses            = [bool]$AutoAssignMfaAndSsoLicenses
            autoAssignHelpDeskVerificationLicenses = [bool]$AutoAssignHelpDeskVerificationLicenses
            autoEnableMfa                          = [bool]$AutoEnableMfa
            autoSendWelcomeEmails                  = [bool]$AutoSendWelcomeEmails
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/ldap_directories' -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $dir = $response.data

            if ($dir -is [pscustomobject]) {
                $dir.PSObject.TypeNames.Insert(0, 'Evo.LdapDirectory')
            }

            Write-Output $dir
        }
        else {
            Write-Output $response
        }
    }
}
