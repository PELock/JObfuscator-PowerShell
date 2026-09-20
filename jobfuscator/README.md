# JObfuscator — PowerShell SDK

**[JObfuscator](https://www.pelock.com/products/jobfuscator)** obfuscates Java source against reverse engineering.

API: https://www.pelock.com/api/jobfuscator/v1

## Installation

```powershell
Install-Module -Name JObfuscator
```

or

```powershell
Install-PSResource -Name JObfuscator
```

```powershell
using module JObfuscator
# or:
Import-Module JObfuscator
$client = New-JObfuscator -ApiKey 'ABCD-ABCD-ABCD-ABCD'
```

## Usage

Most strategy flags default to `$true` (`split_strings` defaults to `$false`), matching the PHP SDK.

```powershell
using module JObfuscator

$client = New-JObfuscator -ApiKey 'ABCD-ABCD-ABCD-ABCD'
$result = $client.ObfuscateJavaSource($javaSource)
if ($result -and $result.error -eq [JObfuscator]::ERROR_SUCCESS) {
    Write-Host $result.output
}
```

See `examples/` for login, default, and full-flag samples.

Author: Bartosz Wójcik / PELock — https://www.pelock.com
