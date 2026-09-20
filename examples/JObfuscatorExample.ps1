################################################################################
#
# JObfuscator WebApi interface usage example.
#
# In this example every PostRequest flag is shown so it can be turned on or off.
#
# Version        : v1.0.0
# Language       : PowerShell
# Author         : Bartosz Wójcik
# Web page       : https://www.pelock.com
#
################################################################################

using module '..\jobfuscator\JObfuscator.psd1'

$myJObfuscator = [JObfuscator]::new('ABCD-ABCD-ABCD-ABCD')

$myJObfuscator.enable_compression = $true
$myJObfuscator.array_int_crypt = $true
$myJObfuscator.array_char_crypt = $true
$myJObfuscator.array_double_crypt = $true
$myJObfuscator.array_string_crypt = $true
$myJObfuscator.remove_comments = $true
$myJObfuscator.split_strings = $true
$myJObfuscator.crypt_strings = $true
$myJObfuscator.rename_methods = $true
$myJObfuscator.shuffle_methods = $true
$myJObfuscator.ints_math_crypt = $true
$myJObfuscator.dbls_math_crypt = $true
$myJObfuscator.rename_variables = $true
$myJObfuscator.mix_code_flow = $true
$myJObfuscator.string_char_vault = $true
$myJObfuscator.ints_from_double_math = $true
$myJObfuscator.opaque_mixer_chain = $true
$myJObfuscator.complexify_booleans = $true
$myJObfuscator.try_finally_noise = $true
$myJObfuscator.ints_to_arrays = $true
$myJObfuscator.dbls_to_arrays = $true

$sourceCode = @'
@Obfuscate
class Hello
{
    public static void main(String[] args) {
        String label = "SecretKey";
        System.out.println(label);
    }
}
'@

$result = $myJObfuscator.ObfuscateJavaSource($sourceCode)

if ($result -and $null -ne $result.PSObject.Properties['error']) {
    if ($result.error -eq [JObfuscator]::ERROR_SUCCESS) {
        Write-Host $result.output
    }
    else {
        Write-Host ("An error occurred, error code: {0}" -f $result.error)
    }
}
else {
    Write-Host 'Something unexpected happen while trying to obfuscate the code.'
}
