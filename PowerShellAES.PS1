#PowerShell AES Functions pulled and modified from this gist:

# https://gist.github.com/ctigeek/2a56648b923d198a6e60 

function Create-AesManagedObject($key, $IV, $keySize=128) {
    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
    $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::ECB
    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7 #Tuya requires PKCS padding as it uses Java default
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = $keySize
    if ($IV) {
        if ($IV.getType().Name -eq "String") {
            $aesManaged.IV = [System.Convert]::FromBase64String($IV)
        }
        else {
            $aesManaged.IV = $IV
        }
    }
    if ($key) {
        if ($key.getType().Name -eq "String") {
            $aesManaged.Key = [System.Convert]::FromBase64String($key)
        }
        else {
            $aesManaged.Key = $key
        }
    }
    $aesManaged
}

function Create-AesKey() {
    $aesManaged = Create-AesManagedObject
    $aesManaged.GenerateKey()
    [System.Convert]::ToBase64String($aesManaged.Key)
}

function Encrypt-String($key, $unencryptedString) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($unencryptedString)
    $aesManaged = Create-AesManagedObject $key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    #[byte[]] $fullData = $aesManaged.IV + $encryptedData #Tuya AES not using an IV
    $aesManaged.Dispose()
    [System.Convert]::ToBase64String($encryptedData)
}

function Decrypt-String($key, $encryptedStringWithIV) {
    $bytes = [System.Convert]::FromBase64String($encryptedStringWithIV)
    #$IV = $bytes[0..15]
    $aesManaged = Create-AesManagedObject -key $key #$IV
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 0, $bytes.length)
    #$unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16); #Tuya AES not using an IV
    $aesManaged.Dispose()
    [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
}

