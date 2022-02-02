Param (
    [Parameter(Mandatory = $true)]
    [string]$Url,
    [parameter(Mandatory = $true)]
    [string] $Checksum,
    [parameter(Mandatory = $true)]
    [string] $ChecksumType,
    [Parameter(Mandatory = $false)]
    [string]$FontFilesFilter = '*'

) #end param

cinst chocolatey-font-helpers.extension -y

Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1" -Force
$toolsDir = (Join-Path "$(Split-Path -parent $MyInvocation.MyCommand.Definition)" 'fonts')

$uri = $url -as [System.Uri]
$fileName = $uri.Segments[($uri.Segments.Length - 1)]
$fileExtension = (New-Object System.IO.FileInfo($fileName)).Extension

Write-Host "Downloading font file $fileName ..." -ForegroundColor Green
if ($fileExtension.ToLower() -eq '.zip') {
    $env:ChocolateyPackageFolder = $toolsDir
    Install-ChocolateyZipPackage -PackageName customfont -Url $Url -UnzipLocation $toolsDir -ChecksumType $ChecksumType -Checksum $Checksum
}
else {
    Get-ChocolateyWebFile -PackageName customfont -Url $Url -FileFullPath (Join-Path $toolsDir $fileName) -ChecksumType $ChecksumType -Checksum $Checksum
}

$fontFiles = Get-ChildItem $toolsDir -Recurse -Filter $FontFilesFilter

Write-Host "Installing font file $fileName ..." -ForegroundColor Green
Install-ChocolateyFont $fontFiles.FullName -multiple

Remove-Item $toolsDir -Recurse
