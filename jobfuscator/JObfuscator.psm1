################################################################################
#
# JObfuscator Web API client for PowerShell.
# Obfuscate and protect Java source against analysis.
#
# Version      : PowerShell SDK v1.0.0
# PowerShell   : Windows PowerShell 5.1 / PowerShell 7+
# Author       : Bartosz Wójcik (support@pelock.com)
# Project      : https://www.pelock.com/products/jobfuscator
# Homepage     : https://www.pelock.com
#
################################################################################

Set-StrictMode -Version Latest

if ($PSVersionTable.PSVersion.Major -lt 6) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
}

Add-Type -AssemblyName System.IO.Compression | Out-Null

$script:JoApiUrl = 'https://www.pelock.com/api/jobfuscator/v1'
$script:JoUserAgent = 'PELock JObfuscator'
$script:JoTimeoutSec = 3600

function Get-JoAdler32 {
    param([Parameter(Mandatory)] [byte[]]$Data)

    $modAdler = 65521
    $a = 1
    $b = 0

    foreach ($byte in $Data) {
        $a = ($a + $byte) % $modAdler
        $b = ($b + $a) % $modAdler
    }

    return [uint32](($b -shl 16) -bor $a)
}

function Compress-JoZlib {
    param([Parameter(Mandatory)] [string]$Source)

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Source)
    $ms = New-Object System.IO.MemoryStream
    try {
        $deflate = New-Object System.IO.Compression.DeflateStream($ms, [System.IO.Compression.CompressionMode]::Compress, $true)
        try {
            $deflate.Write($bytes, 0, $bytes.Length)
        }
        finally {
            $deflate.Dispose()
        }

        $deflated = $ms.ToArray()
    }
    finally {
        $ms.Dispose()
    }

    $adler = Get-JoAdler32 -Data $bytes
    $output = New-Object byte[] ($deflated.Length + 6)
    $output[0] = 0x78
    $output[1] = 0xDA
    [Buffer]::BlockCopy($deflated, 0, $output, 2, $deflated.Length)
    $output[$output.Length - 4] = [byte](($adler -shr 24) -band 0xFF)
    $output[$output.Length - 3] = [byte](($adler -shr 16) -band 0xFF)
    $output[$output.Length - 2] = [byte](($adler -shr 8) -band 0xFF)
    $output[$output.Length - 1] = [byte]($adler -band 0xFF)

    return [Convert]::ToBase64String($output)
}

function Expand-JoZlib {
    param([Parameter(Mandatory)] [string]$CompressedBase64)

    $data = [Convert]::FromBase64String($CompressedBase64)
    if ($data.Length -lt 6) {
        throw 'Invalid zlib payload.'
    }

    $payloadLength = $data.Length - 6
    $ms = New-Object System.IO.MemoryStream($data, 2, $payloadLength)
    try {
        $deflate = New-Object System.IO.Compression.DeflateStream($ms, [System.IO.Compression.CompressionMode]::Decompress)
        try {
            $reader = New-Object System.IO.StreamReader($deflate, [System.Text.Encoding]::UTF8)
            try {
                return $reader.ReadToEnd()
            }
            finally {
                $reader.Dispose()
            }
        }
        finally {
            $deflate.Dispose()
        }
    }
    finally {
        $ms.Dispose()
    }
}

function ConvertTo-JoFormBody {
    param([Parameter(Mandatory)] [hashtable]$Fields)

    $parts = foreach ($key in $Fields.Keys) {
        $name = [uri]::EscapeDataString([string]$key)
        $value = [uri]::EscapeDataString([string]$Fields[$key])
        '{0}={1}' -f $name, $value
    }

    return ($parts -join '&')
}

function Invoke-JoApiRequest {
    param([Parameter(Mandatory)] [hashtable]$Fields)

    $body = ConvertTo-JoFormBody -Fields $Fields
    $headers = @{ 'User-Agent' = $script:JoUserAgent }

    try {
        return Invoke-RestMethod -Uri $script:JoApiUrl -Method Post -Body $body `
            -ContentType 'application/x-www-form-urlencoded' -Headers $headers `
            -TimeoutSec $script:JoTimeoutSec
    }
    catch {
        return $false
    }
}

class JObfuscator {
    static [string] $API_URL = 'https://www.pelock.com/api/jobfuscator/v1'

    hidden [string] $_api_key = ''

    [bool] $enable_compression = $true
    [bool] $array_int_crypt = $true
    [bool] $array_char_crypt = $true
    [bool] $array_double_crypt = $true
    [bool] $array_string_crypt = $true
    [bool] $remove_comments = $true
    [bool] $split_strings = $false
    [bool] $crypt_strings = $true
    [bool] $rename_methods = $true
    [bool] $shuffle_methods = $true
    [bool] $ints_math_crypt = $true
    [bool] $dbls_math_crypt = $true
    [bool] $rename_variables = $true
    [bool] $mix_code_flow = $true
    [bool] $string_char_vault = $true
    [bool] $ints_from_double_math = $true
    [bool] $opaque_mixer_chain = $true
    [bool] $complexify_booleans = $true
    [bool] $try_finally_noise = $true
    [bool] $ints_to_arrays = $true
    [bool] $dbls_to_arrays = $true

    static [int] $ERROR_SUCCESS = 0
    static [int] $ERROR_INPUT_SIZE = 1
    static [int] $ERROR_INPUT = 2
    static [int] $ERROR_PARSING = 3
    static [int] $ERROR_OBFUSCATION = 4
    static [int] $ERROR_OUTPUT = 5

    JObfuscator() {
        $this.Initialize($null)
    }

    JObfuscator([string]$ApiKey) {
        $this.Initialize($ApiKey)
    }

    hidden [void] Initialize([string]$ApiKey) {
        $this._api_key = $ApiKey
        $this.enable_compression = $true
        $this.array_int_crypt = $true
        $this.array_char_crypt = $true
        $this.array_double_crypt = $true
        $this.array_string_crypt = $true
        $this.remove_comments = $true
        $this.split_strings = $false
        $this.crypt_strings = $true
        $this.rename_methods = $true
        $this.shuffle_methods = $true
        $this.ints_math_crypt = $true
        $this.dbls_math_crypt = $true
        $this.rename_variables = $true
        $this.mix_code_flow = $true
        $this.string_char_vault = $true
        $this.ints_from_double_math = $true
        $this.opaque_mixer_chain = $true
        $this.complexify_booleans = $true
        $this.try_finally_noise = $true
        $this.ints_to_arrays = $true
        $this.dbls_to_arrays = $true
    }

    [object] Login() {
        $params = @{ command = 'login' }
        return $this.PostRequest($params)
    }

    [object] ObfuscateJavaFile([string]$JavaFilePath) {
        if (-not (Test-Path -LiteralPath $JavaFilePath -PathType Leaf)) {
            return $false
        }

        try {
            $source = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $JavaFilePath).Path)
        }
        catch {
            return $false
        }

        if ([string]::IsNullOrEmpty($source)) {
            return $false
        }

        return $this.ObfuscateJavaSource($source)
    }

    [object] obfuscate_java_file([string]$java_file_path) {
        return $this.ObfuscateJavaFile($java_file_path)
    }

    [object] ObfuscateJavaSource([string]$JavaSource) {
        $params = @{
            command = 'obfuscate'
            source  = $JavaSource
        }

        return $this.PostRequest($params)
    }

    [object] obfuscate_java_source([string]$java_source) {
        return $this.ObfuscateJavaSource($java_source)
    }

    [object] PostRequest([hashtable]$ParamsArray) {
        if ($this._api_key) {
            $ParamsArray['key'] = $this._api_key
        }

        $flags = @(
            'array_int_crypt',
            'array_char_crypt',
            'array_double_crypt',
            'array_string_crypt',
            'remove_comments',
            'split_strings',
            'crypt_strings',
            'rename_methods',
            'shuffle_methods',
            'ints_math_crypt',
            'dbls_math_crypt',
            'rename_variables',
            'mix_code_flow',
            'string_char_vault',
            'ints_from_double_math',
            'opaque_mixer_chain',
            'complexify_booleans',
            'try_finally_noise',
            'ints_to_arrays',
            'dbls_to_arrays'
        )

        foreach ($flag in $flags) {
            if ($this.$flag) {
                $ParamsArray[$flag] = '1'
            }
        }

        if ($ParamsArray.ContainsKey('source') -and $this.enable_compression -and $ParamsArray['source']) {
            $ParamsArray['source'] = Compress-JoZlib -Source ([string]$ParamsArray['source'])
            $ParamsArray['compression'] = '1'
        }

        $result = Invoke-JoApiRequest -Fields $ParamsArray
        if ($result -eq $false -or $null -eq $result) {
            return $false
        }

        $errorCode = 0
        $errorProperty = $result.PSObject.Properties['error']
        if ($null -ne $errorProperty) {
            $errorCode = [int]$errorProperty.Value
        }

        $outputProperty = $result.PSObject.Properties['output']
        if ($null -ne $outputProperty -and $this.enable_compression -and $errorCode -eq [JObfuscator]::ERROR_SUCCESS) {
            $result.output = Expand-JoZlib -CompressedBase64 ([string]$outputProperty.Value)
        }

        return $result
    }

    [object] post_request([hashtable]$params_array) {
        return $this.PostRequest($params_array)
    }
}

function New-JObfuscator {
    <#
    .SYNOPSIS
        Creates a JObfuscator Web API client.

    .DESCRIPTION
        Factory for the JObfuscator class. Empty or invalid keys run demo mode.
        Most strategy flags default to $true (split_strings defaults to $false),
        matching the PHP SDK PostRequest surface.

    .PARAMETER ApiKey
        Activation key from PELock.

    .EXAMPLE
        $client = New-JObfuscator -ApiKey 'ABCD-ABCD-ABCD-ABCD'
        $result = $client.ObfuscateJavaSource($javaSource)
    #>
    [CmdletBinding()]
    [OutputType([JObfuscator])]
    param(
        [string]$ApiKey
    )

    if ([string]::IsNullOrWhiteSpace($ApiKey)) {
        return [JObfuscator]::new($null)
    }

    return [JObfuscator]::new($ApiKey)
}

Export-ModuleMember -Function @('New-JObfuscator')
