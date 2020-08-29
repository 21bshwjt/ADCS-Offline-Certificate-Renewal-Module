$CertFileSST = (Get-ChildItem -Path C:\Output\$env:COMPUTERNAME.sst)
$CertFileSST | Import-Certificate -CertStoreLocation Cert:\LocalMachine\My