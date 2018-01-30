Param (
    $devId="12345678901234567890", #Tuya device ID
    $asciiKey="0123456789ABCDEF", #Tuya device key, 16-digit hexedecimal representation of a b64 AES-128 key
    $action="false",
    $timeoffset=10, #Adds a few seconds so the time is correct by the time I paste the message!
    $mqttVersion="2.1" #Detected version from phone app is 2.1, 'tuyapi' project appears to use 3.1
)

#Script to encrypt an MQTT message - will work with direct messages too.

Set-Location $PSScriptRoot
. .\hexTools.PS1
. .\PowerShellAES.PS1

#Construct the ON/OFF message
$unixTime = [int][double]::Parse((Get-Date -UFormat %s)) + $timeoffset

$Template = '{{"protocol":4,"t":{2},"data":{{"devId":"{0}","dps":{{"1":{1}}}}},"s":2}}'
#$Template = '{{"data":{{"devId":"{0}","dps":{{"1":{1}}}}},"protocol":5,"s":-1,"t":{2}}}'
#$Template = '{{"devId":"{0}","dps":{{"1":{1}}},"uid":"","t":"{2}"}}'

$Message = $Template -f $devId, $action, $unixtime

#Make the Hex-based key into a 24-Character, 128-Bit AES key

$hexArray = [char[]]$asciiKey | ForEach-Object {'{0:X}' -f [byte]$_}
$hexKey = -join $hexArray
$keybytes = Convert-HexToByteArray -HexString $hexKey
$b64key = [System.Convert]::ToBase64String($keybytes)
$encryptedMessage = Encrypt-String -key $b64key -unencryptedString $Message

#Tuyapi seems to use 'lpv=' instead of 'pv='
$md5Template = "data={0}||pv={1}||{2}"
$md5toCalc = $md5Template -f $encryptedMessage, $mqttVersion, $asciiKey

#Encrypt the datas
Write-Host "---------------------------------------------" -ForegroundColor Blue
Write-Host "Encrypt message with ascii key: " -NoNewline
Write-Host $asciiKey -ForegroundColor Yellow
Write-Host "Encrypt: $($message)"
Write-Host "With Key: $($b64key)"
Write-Host "Output: $($encryptedMessage)" -ForegroundColor Green
Write-Host "md5 of: $($md5toCalc)" -ForegroundColor Green


. .\md5-function.ps1
[String]$myMD5 = getMD5 -source $md5toCalc

Write-Host "MD5: $myMD5"

$antiTamper = $myMD5.Substring(8,16).ToLower()

Write-Host "antiTamper:  $antiTamper"

$fullMessage = "DATA = $($mqttVersion)$($antiTamper)$($encryptedMessage)"
Write-Host $fullMessage -ForegroundColor Yellow
