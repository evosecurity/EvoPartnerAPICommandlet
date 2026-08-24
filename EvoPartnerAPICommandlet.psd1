@{
    RootModule        = 'EvoPartnerAPICommandlet.psm1'
    ModuleVersion     = '0.5.0'
    GUID              = '11111111-2222-3333-4444-555555555555'
    Author            = 'Evo Security'
    CompanyName       = 'Evo Security'
    Copyright         = '(c) Evo Security. All rights reserved.'
    Description       = 'PowerShell module for the Evo Partner API.'

    PowerShellVersion = '5.1'

    # During development we allow all functions; the .psm1 will only export Public/*.ps1
    FunctionsToExport = @('*')
    CmdletsToExport   = @()
    AliasesToExport   = @()
    VariablesToExport = @()

    PrivateData       = @{
        PSData = @{
            Tags        = @('Evo','Partner','API')
            ProjectUri  = 'https://evosecurity.com'
            LicenseUri  = 'https://evosecurity.com'
            ReleaseNotes = 'Added RBAC v2 cmdlets (Get/New/Set/Remove-EvoRbacRole, Get-EvoPermission, Get-EvoPermissionCatalog, the Get/Add/Remove-EvoRbacRoleAssignedUser|Group role-side pair, and Get/Add/Remove-Evo{User,Group}RbacRole plus their Bulk variants). Legacy role group cmdlets are unchanged and remain supported.'
        }
    }
}
