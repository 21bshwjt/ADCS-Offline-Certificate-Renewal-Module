##################################################################################
Function Global:Get-Pax {
$Global:passpass = Read-Host -Prompt 'Input PWD'
$Global:securepass = ConvertTo-SecureString -AsPlainText $Global:passpass -Force
$Global:Username = Read-Host -Prompt "Input UserID as UPN Format"
$Global:mycred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:Username,$Global:securepass
$Global:Hostname = Read-Host -Prompt 'Input Server FQDN'
$Global:PSLocation = "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PKIMgmt\PKIMgmt.ps1"
$Global:SecureWinRMSession = New-PSSession -ComputerName $Global:Hostname -Credential $Global:mycred -UseSSL
$Global:PKIServer = "test-CA01.Contoso.com\ContosoIssuingCA"
$Global:Tmpl3 = "KerberosAuthentication-offline"
$Global:Tmpl2 = "DomainControllerAuthentication-Offline"
$Global:Location = "C:\Output"
$Global:Cert = "C:\Output\$Hostname.cer"
$Global:Req ="C:\Output\$Hostname.req"
  }
##################################################################################
Function Set-DCCert-Tmpl3 {

Function Set-DCNewCert-Remotely {
  Write-Progress "Certificate Renewal is in progress.............."
  Global:Get-Pax
  Invoke-Command -FilePath $PSLocation -Credential $mycred -ComputerName $Hostname -UseSSL
  Write-Host "CSR Generation is completed" -NoNewline
  Write-Host " succesfully" -ForegroundColor Green
  Set-Location $Location
  Copy-Item -Path $req -Destination $Location -FromSession $SecureWinRMSession
  Certreq -Submit -q -attrib "CertificateTemplate:$Tmpl3" -Config $PKIServer .\$Hostname.req .\$Hostname.cer
  Copy-Item -Path $Cert -Destination $Location -ToSession $SecureWinRMSession
  $SecureWinRMSession | Remove-PSSession
  Invoke-Command -ComputerName $Hostname -Credential $mycred -UseSSL -ScriptBlock { 
  #Remove All Existing Certicicate from the Store (Cert:\LM\MY) but you can select the NO
  Get-ChildItem -Path Cert:\LocalMachine\my\* | Remove-Item -Confirm:$true -Verbose
  $DCCertkerb = ("$env:COMPUTERNAME"+"."+"$env:USERDNSDOMAIN"+"."+"cer")
  Import-Certificate -FilePath "C:\Output\$DCCertkerb" -CertStoreLocation 'Cert:\LocalMachine\My' -Verbose
  #Delete Https WinRM Listener
  winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
  #Create Https WinRM Listener
  winrm create winrm/config/Listener?Address=*+Transport=HTTPS | Out-Null
  #Set RDP SSL binding
  <#$RDPThumbPrint = (Get-ChildItem Cert:\LocalMachine\My).Thumbprint
  $RDPThumbPrint | Out-Null
  $RDPpath = (Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'").__path
  Set-WmiInstance -Path $RDPpath -argument @{SSLCertificateSHA1Hash="$RDPThumbPrint"} | Out-Null#>
  #Start-Sleep 5
  Remove-Item -Path c:\output\*.cer -Force
  Remove-Item -Path c:\output\*.req -Force
  Remove-Item -Path c:\output\*.rsp -Force
  Remove-Item -Path c:\output\*.inf -Force
 
       }
  Remove-Item -Confirm:$true -Path "$Location\*.cer"
  Remove-Item -Confirm:$true -Path "$Location\*.req"
  Remove-Item -Confirm:$true -Path "$Location\*.rsp"
  Write-Host ""
  Write-Host "1. " -ForegroundColor Green -NoNewline
  Write-Host "Certificate Renewal Completed" -NoNewline -ForegroundColor Yellow
  Write-Host " Successfully" -ForegroundColor Green
  Write-Host "2. " -ForegroundColor Green -NoNewline
  Write-Host "Deleted the Request & Certificate files from" -NoNewline -ForegroundColor Yellow
  Write-Host " Local" -NoNewline -ForegroundColor Green
  Write-Host " &" -NoNewline -ForegroundColor Yellow
  Write-Host " Remote" -NoNewline -ForegroundColor Green
  Write-host " Computers" -ForegroundColor Yellow
       }
  Set-DCNewCert-Remotely | Tee-Object -Append -FilePath "C:\Cert.log"
  }

       
##################################################################################
Function Recover-Certificate {
Set-Location C:\Output
$ReqID = Read-Host "Please Enter Request ID"
Certreq -retrieve $ReqID SRV.cer

}
##################################################################################
Function Export-CertificateStore {
$passpass = Read-Host -Prompt 'Please Input PWD'
$securepass = ConvertTo-SecureString -AsPlainText $passpass -Force
$Username = Read-Host -Prompt "Input UserID as UPN Format"
$mycred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$securepass
$Hostname = Read-Host -Prompt 'Input Server FQDN'
$SecureSession = New-PSSession -ComputerName $Hostname -Credential $mycred -UseSSL
Write-Progress "Exporting Certificate Store"
Copy-Item -Path C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PKIMgmt\ExportSST.ps1 -Destination 'C:\Output' -ToSession $SecureSession
Invoke-Command -Session $SecureSession -ScriptBlock {
Start-Process C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ArgumentList  "-file C:\Output\ExportSST.ps1" -WindowStyle Hidden
Sleep 3
Remove-Item C:\Output\ExportSST.ps1
}
sleep 3
$SecureSession | Remove-PSSession
Write-Host "Certificate Store (Cert:\LocalMachine\My) has been exported" -NoNewline
Write-Host " Successfully" -ForegroundColor Green -NoNewline
Write-Host " Location C:\Output"

}
################################################################################################
Function Import-CertificateStore {
$passpass = Read-Host -Prompt 'Please Input PWD'
$securepass = ConvertTo-SecureString -AsPlainText $passpass -Force
$Username = Read-Host -Prompt "Input UserID as UPN Format"
$mycred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$securepass
$Hostname = Read-Host -Prompt 'Input Server FQDN'
$SecureSession = New-PSSession -ComputerName $Hostname -Credential $mycred -UseSSL
Write-Progress "Importing Certificate Store"
Copy-Item -Path C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PKIMgmt\ImportSST.ps1 -Destination 'C:\Output' -ToSession $SecureSession
Invoke-Command -Session $SecureSession -ScriptBlock {
Start-Process C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ArgumentList  "-file C:\Output\ImportSST.ps1" -WindowStyle Hidden
Sleep 3
Remove-Item C:\Output\ImportSST.ps1
Remove-Item C:\Output\$env:COMPUTERNAME.sst
}
sleep 3
$SecureSession | Remove-PSSession
Write-Host "Certificate Store (Cert:\LocalMachine\My) has been imported" -NoNewline
Write-Host " Successfully" -ForegroundColor Green -NoNewline

}
################################################################################################
Function Get-RDPSslBind {
$results = Invoke-Command -ComputerName (Get-Content C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PKIMgmt\Logs\ContosoDCs.txt) -UseSSL -ScriptBlock {
Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'" | 
select pscomputername,Terminalname,SSLCertificateSHA1HashType,SSLCertificateSHA1Hash
}
$results | FT -AutoSize -Wrap
}
    
################################################################################################
Function Test-SslWinRM-DCs {
$Srvs = Get-Content C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PKIMgmt\Logs\DCs.txt
$ErrorActionPreference = "Stop" 
foreach ($Srv in $Srvs) 
{
 Write-Progress "Running SslWinRM test on CONTOSO Domain Controllers........."
 Try
 {
 Test-WSMan -ComputerName $Srv -UseSSL | Out-Null

Write-Host $Srv.ToUpper() -NoNewline | Sort-Object
Write-Host ":" -NoNewline
Write-host " Passed " -foreground Green
 }
 catch
 {
Write-Host $Srv.ToUpper() -NoNewline
Write-Host ":" -NoNewline
Write-host " Failed" -foreground Red
}
  }
Write-Host " "
Write-Host "SslWinRM test completed Successfully" -ForegroundColor Yellow
    }
################################################################################################