Param(
  $asciiKey = "8bb486f35dbc57dd", #This is the 16-digit hex string 'key' from your device,
  $publishedMessage = "2.1f965e98d6db781a6YzE/13Vp6p84PA1dV/1rACuvQlqIDsHDjpzZF5hqvPLdWu0bd7SKADwzK893HfHKMl4rdHb5Qc1qPOqfSFVcD1eqGhvwDO7pqCLmArcUpYDSEiSjFCfRKh1hnsbZrXEj" #The encoded Tuya message
)

#Decode an MQTT message from device / cloud or phone

#Example key and message from the following URL

# https://docs.tuya.com/en/cloudapi/device_access.html 

Set-Location $PSScriptRoot
. .\hexTools.PS1

$version = $publishedMessage.substring(0,3)
$antiTamper = $publishedMessage.substring(3,16)
$b64data = $publishedMessage.substring(19,$publishedMessage.Length-19)

$md5Template = "data={0}||pv={1}||{2}"
$md5toCalc = $md5Template -f $b64data, $version, $asciiKey

#There has to be a better way to do this!
$hexArray = [char[]]$asciiKey | ForEach-Object {'{0:X}' -f [byte]$_}
$hexKey = -join $hexArray

$keybytes = Convert-HexToByteArray -HexString $hexKey
$b64key = [System.Convert]::ToBase64String($keybytes)

. .\PowerShellAES.PS1


$outStr = . Decrypt-String -key $b64key -encryptedStringWithIV $b64data

if ($outStr[0] -eq "{" -and $outStr[1] -eq "`"") {
  Write-Host "---------------------------------------------" -ForegroundColor Blue
  Write-Host "Trying ascii key: " -NoNewline
  Write-Host $asciiKey -ForegroundColor Yellow
  Write-Host "Proto Version: $($version)"
  . .\md5-function.ps1
  [String]$myMD5 = getMD5 -source $md5toCalc
  Write-Host "MD5: $myMD5"
  $antiTamperCalc = $myMD5.Substring(8,16).ToLower()
  Write-Host "Calculated Anti Tamper from data: $($antiTamperCalc)"
  Write-Host "REAL    Anti Tamper from message: $($antiTamper)"
  Write-Host "Decrypt: $($b64data)"
  Write-Host "With Key: $($b64key)"
  #Write-Host "Output: $($outStr -replace '[^\x30-\x39\x41-\x5A\x61-\x7A]+', '')" -ForegroundColor Green
  Write-Host "Output: $($outStr)" -ForegroundColor Green
} else {
  #Write-Host "Output: $($outStr -replace '[^\x30-\x39\x41-\x5A\x61-\x7A]+', '')"
}

$outStr

