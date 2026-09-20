################################################################################
#
# JObfuscator WebApi interface usage example.
#
# In this example we will obfuscate sample source with default options.
#
# Version        : v1.0.0
# Language       : PowerShell
# Author         : Bartosz Wójcik
# Web page       : https://www.pelock.com
#
################################################################################

using module '..\jobfuscator\JObfuscator.psd1'

$myJObfuscator = [JObfuscator]::new('ABCD-ABCD-ABCD-ABCD')

$sourceCode = @'
import java.util.*;
import java.lang.*;
import java.io.*;

@Obfuscate
class Ideone
{
    public static double calculateSD(double numArray[])
    {
        double sum = 0.0, standardDeviation = 0.0;
        int length = numArray.length;

        for(double num : numArray) {
            sum += num;
        }

        double mean = sum/length;

        for(double num: numArray) {
            standardDeviation += Math.pow(num - mean, 2);
        }

        return Math.sqrt(standardDeviation/length);
    }

    public static void main(String[] args) {
        double[] numArray = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
        double SD = calculateSD(numArray);
        System.out.format("Standard Deviation = %.6f", SD);
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
