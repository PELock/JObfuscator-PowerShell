@{
    RootModule        = 'JObfuscator.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'c18820a9-63b7-479e-a204-9c515e4ea66f'
    Author            = 'Bartosz Wójcik'
    CompanyName       = 'PELock'
    Copyright         = '(c) 2026 Bartosz Wójcik / PELock. All rights reserved.'
    Description       = 'PowerShell Gallery Web API client for JObfuscator. Obfuscate and protect Java source code via the PELock remote API.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'New-JObfuscator'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @(
                'Java',
                'Obfuscator',
                'Obfuscation',
                'JObfuscator',
                'PELock',
                'API',
                'Security'
            )
            LicenseUri   = 'https://www.apache.org/licenses/LICENSE-2.0'
            ProjectUri   = 'https://www.pelock.com/products/jobfuscator'
            IconUri      = 'https://www.pelock.com/img/en/products/jobfuscator/jobfuscator.png'
            ReleaseNotes = @'
## 1.0.0

- Initial PowerShell Gallery release
- JObfuscator class — Web API client mirroring the PHP SDK PostRequest flags
- New-JObfuscator — factory for the client
'@
        }
    }
}
