################################################################################
#
# JObfuscator WebApi interface usage example.
#
# In this example we will verify our activation key status.
#
# Version        : v1.0.0
# Language       : PowerShell
# Author         : Bartosz Wójcik
# Web page       : https://www.pelock.com
#
################################################################################

using module '..\jobfuscator\JObfuscator.psd1'

$myJObfuscator = [JObfuscator]::new('ABCD-ABCD-ABCD-ABCD')
$result = $myJObfuscator.Login()

if ($result) {
    $demoStatus = if ($result.demo) { 'true' } else { 'false' }
    Write-Host ("Demo version status - {0}" -f $demoStatus)
    Write-Host ("Usage credits left - {0}" -f $result.credits_left)
    Write-Host ("Total usage credits - {0}" -f $result.credits_total)
    Write-Host ("Max. source code size - {0}" -f $result.string_limit)
}
else {
    Write-Host 'Something unexpected happen while trying to login to the service.'
}
