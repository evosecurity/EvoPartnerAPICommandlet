@{
    RootModule        = 'EvoPartnerAPICommandlet.psm1'
    ModuleVersion     = '0.2.0'
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
            ReleaseNotes = 'Initial development version.'
        }
    }
}
