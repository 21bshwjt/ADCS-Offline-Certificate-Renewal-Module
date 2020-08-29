# ADCS-Offline-Certificate-Renewal-Module

**Prerequisites : Powershell Version 5 &  SSL WinRM**

We can use this module where we dont have the local certificate server in the same domain or we dont have the ADDS trust with that domain where we have Certificate server for Certificate Auto-Enrollmemt. We have to run this module at the same domain where Certificate server is present. Import PKIMGMT module in any member server. 
Please note PKIMgmt Module will not work without having Powershell version 5. .Inf , .Req & .Cer files are copied by SSL WinRM & that feather is availabale on Powershell version 5 & onwards. Adjust Global varriables as per your environment. Also you can use WinRM instead of SSL WINRM (Need to remove -usessl switch from that module). Secutiry is completely taken care within this module. There is no use of port 445. Only 5985 & 5986 communications are required . 
