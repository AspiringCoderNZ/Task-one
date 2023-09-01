cd "C:\Users\Administrator"
New-Item -Path "C:\DeploymentShare" -ItemType directory
New-SmbShare -Name "DeploymentShare" -Path "C:\DeploymentShare" -FullAccess Administrators
# import module 
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
# PS drive
New-PSDrive -Name "DS002" -PSProvider "MDTProvider" -Root "C:\DeploymentShare" -Description "MDT Deployment Share" -NetworkPath "\\Server\DeploymentShare" -Verbose | Add-MDTPersistentDrive -Verbose
#import oerating system
PS C:\Users\Administrator> Import-MDTOperatingSystem -Path "DS002:\Operating Systems" -SourcePath "C:\Windows 11" -DestinationFolder "Windows 11" -Verbose
#import Application
Import-MDTApplication -Path "DS002:\Applications" -enable "True" -Name "Adobe reader 9" -ShortName "reader" -Version "9" -Publisher "Adobe" -Language "English" -CommandLine "Reader.exe /sALL /rs /l" -WorkingDirectory ".\Application\Adobe reader 9" -ApplicationSourcePath "C:\Adobe" -DestinationFolder "Adobe reader 9" -Verbose
#Import MDT Task Sequence
Import-MDTTaskSequence -Path "DS002:\Task Sequences" -Name "Win11" -Template "Client.xml" -Comments "Deploying Win11" -ID "1" -Version "1.0" -OperatingSystemPath "DS002:\Operating Systems\Windows 11 Pro in Windows 11 install.wim" -FullName "Windows Users" -OrgName "Aspire2" -Verbose
# update custom settings ini
Remove-Item -Path "C:\DeploymentShare\Control\CustomSettings.ini" -Force
New-Item -Path "C:\DeploymentShare\Control\CustomSettings.ini" -ItemType File 
Set-Content -Path "C:\DeploymentShare\Control\CustomSettings.ini" -Value (Get-Content "C:\Users\Administrator\Desktop\New folder\CustomSettings.ini")
#update bootstrap
Remove-Item -Path "C:\DeploymentShare\Control\Bootstrap.ini" -Force
New-Item -Path "C:\DeploymentShare\Control\Bootstrap.ini" -ItemType File 
Set-Content -Path "C:\DeploymentShare\Control\Bootstrap.ini" -Value (Get-Content "C:\Users\Administrator\Desktop\New folder\Bootstrap.ini")
# put in right information for Bootstrap txt and customsettings txt
#disable version X86
$XMLFile = "C:\DeploymentShare\Control\Settings.xml"
[xml]$SettingsXML = Get-Content $XMLFile
$SettingsXML.Settings."SupportX86" = "False"
$SettingsXML.Save($XMLFile)
#Update deployment share to create boot wims and iso file
Update-MDTDeploymentShare -Path "DS002:" -Force -Verbose
#installing WDS role in the server
Install-WindowsFeature -Name WDS -IncludeManagementTools
#initialize WDS server
$WDSPath = "C:\RemoteInstall"
wdsutil /Verbose /Progress /Initialize-Server /RemInst:$WDSPath
# enable answering client
WDSUTIL /Set-Server /AnswerClients:All
#iMPORT iMAGE FILE
Import-WdsBootImage -Path C:\DeploymentShare\Boot\LiteTouchPE_x64.wim -NewImageName "LiteTouchPE_x64" -SkipVerify