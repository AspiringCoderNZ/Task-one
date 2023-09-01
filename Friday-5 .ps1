# installing Windows ADK 
cd "C:\Users\Administrator\Desktop\New folder\Windows Kits\10\ADK" 
Start-Process -FilePath adksetup.exe -ArgumentList "/S" -Wait
#Install Windows PE
cd "C:\Users\Administrator\Desktop\New folder\Windows Kits\10\ADKWinPEAddons" 
Start-Process -FilePath adkwinpesetup.exe -ArgumentList "/S" -Wait



