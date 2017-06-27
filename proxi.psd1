@{
    ModuleToProcess = 'proxi.psm1'
    ModuleVersion = '0.0.0'
    GUID = 'b6f34c11-2270-4d7d-8a26-96de60a3b5ea'
    Author = 'Stephen Phillips'
    Copyright = '(c) 2017 Stephen Phillips'
    Description = 'A module that can be used to bootstrap other scripts via a single entry point.'
    PowerShellVersion = '2.0'
    FunctionsToExport = @(
        'Proxi',
        'TabExpansion'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('script-proxy', 'bootstrapper')
            LicenseUri = 'https://raw.githubusercontent.com/Korthax/PowershellScriptRunner/master/LICENSE'
            ProjectUri = 'https://github.com/Korthax/PowershellScriptRunner'
        }
    }
}