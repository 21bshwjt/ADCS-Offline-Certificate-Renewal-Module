#This Script will create a CSR with SAN
 #Version : 1.0
 #DATE : 20-May-17
 $path = "C:\Output"
 If(!(test-path $path))
 {
 New-Item -ItemType Directory -Force -Path $path
 }
 $SrvFQDN = ("$env:COMPUTERNAME"+"."+"$env:USERDNSDOMAIN").ToUpper()
 $Path
 $SetINF = $null
 $SetINF = "[NewRequest]"
 $SetINF += "`r`n"
 $SetINF += "Subject = ""CN=$SrvFQDN""`r`n"
 $SetINF += "Exportable = TRUE`r`n"
 $SetINF += "KeyLength = 2048`r`n"
 $SetINF += "KeySpec = 1`r`n"
 $SetINF += "KeyUsage = 0xA0`r`n"
 $SetINF += "MachineKeySet = TRUE`r`n"
 $SetINF += "ProviderType = 12`r`n"
 $SetINF += "SMIME = FALSE`r`n"
 $SetINF += "RequestType = CMC`r`n"
 #$SetINF += "[RequestAttributes]`r`n"
 #$SetINF += "CertificateTemplate = DomainControllerAuthentication-Offline`r`n"
 $SetINF | out-file -filepath $path\$SrvFQDN.inf
 sleep 5
 certreq -f -new $path\$SrvFQDN.inf $path\$SrvFQDN.req

