<#

#JAVA Code from https://docs.tuya.com/en/cloudapi/device_access.html for their 'special' md5 function
# Turns out it's just regular MD5 and their example strings are not formed correctly.

public static String getMD5 (byte [] source) throws Exception {
    String s = null;
    Char [] hexDigits = new char [] {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9' 'A', 'b', 'c', 'd', 'e', ​​'f'};

    MessageDigest e = MessageDigest.getInstance ("MD5");
    E.update (source);
    Byte [] tmp = e.digest ();
    Char [] str = new char [32];
    Int k = 0;
    For (int i = 0; i & lt; 16; ++ i) {   #(0 to 15?)
        Byte byte0 = tmp [i];
        Str [k ++] = hexDigits [byte0 >>> 4 & 15]; #b0 shiftright 4 band 15
        Str [k ++] = hexDigits [byte0 & 15]; #b0 band 15
    }}
    S = new String (str);
    Return s;
}}

#>

function getMD5 {
    <#This is actually pointless, the code is just a straight port of the Tuya Java code
        Regular PowerShell MD5 will produce the same result. Leaving this here because it works!
        #>
    Param(
        [String]$source
    )

    [Char[]]$hexDigits='0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'b', 'c', 'd', 'e', 'f'
    
    $md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    $utf8 = new-object -TypeName System.Text.UTF8Encoding
    #$utf8 = new-object -TypeName System.Text.ASCIIEncoding
    $tmp = $md5.ComputeHash($utf8.GetBytes($source))
    [Char[]]$Str = (1..32 | ForEach-Object {0})
    #($Str -join "").toUpper()

    [Int]$k = 0
    foreach ($i in (0..15)) {
        [Byte]$byte0 = $tmp[$i]
        $Str[$k] = $hexDigits[$byte0 -shr 4 -band 15]
        #Write-Host "k=$($k), arrayElement = $($byte0 -shr 4 -band 15) str=$(($Str -join '').toUpper())"
        $k++
        $Str[$k] = $hexDigits[$byte0 -band 15]
        #Write-Host "k=$($k), arrayElement = $($byte0 -band 15) str=$(($Str -join '').toUpper())"
        $k++
    }
    return ($Str -join "").toUpper()
}