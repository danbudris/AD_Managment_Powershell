$script = read-host -prompt "Input script name to sign"

$cert =(dir cert:currentuser\my -CodeSigningCert)

Set-AuthenticodeSignature $script $cert -TimestampServer http://timestamp.comodoca.com/authenticode
