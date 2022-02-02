param (
    [Parameter(Mandatory=$true)][string]$Name
   ,[Parameter(Mandatory=$true)][string]$Url
 ) #end param

 Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1" -Force

 $packageNameVsix = -Join($Name,'.vsix')
 $toolsDir = (Join-Path "$(Split-Path -parent $MyInvocation.MyCommand.Definition)" 'vsix')
 $installPath = (Get-VSSetupInstance).InstallationPath

 if(!$installPath) {
     throw "There was an error finding latest Visual Studio install location. Please make sure Visual Studio (2019 or later) is installed correctly."
 }

 $vsixInstaller = gci -File -Recurse -Filter vsixinstaller.exe -Path $installPath

 Write-Host "Downloading the $Name Visual Studio 2019 Extension ... "
 New-Item -Path $toolsDir  -ItemType directory -Force
 (New-Object System.Net.WebClient).DownloadFile($Url, (Join-Path $toolsDir $packageNameVsix))

 Write-Host "Installing the $Name Visual Studio 2019 Extension ... "
 $result = Install-Vsix -Installer $vsixInstaller.FullName -InstallFile (Join-Path $toolsDir $packageNameVsix)

 if($result -eq 2004) { #2004: Blocking Process (need to close VS)
     throw "A process is blocking the installation of the Visual Studio Extension. Please close all Visual Studio instances and try again."
 }

 if($result -gt 0 -and $result -ne 1001) { #1001: Already installed
     throw "There was an error installing the $Name Visual Studio 2019 Extension. The exit code returned was $result."
 }

 Write-Host "Successfully installed the $Name Visual Studio 2019 Extension." -ForegroundColor Green
