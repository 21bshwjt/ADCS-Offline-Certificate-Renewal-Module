Get-ChildItem -Path Cert:\LocalMachine\My | Export-Certificate -FilePath C:\Output\$env:COMPUTERNAME.sst -Type SST