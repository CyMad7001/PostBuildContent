param(
    [Parameter()][string][ValidateSet('2019','2022')]$Version='2022'
   ,[Parameter()][string][ValidateSet('Professional','Enterprise')]$Sku='Professional'
)

if (!(Get-Module -Name VSSetup)) {
    if (!(Get-Module -Name VSSetup -ListAvailable)) {
        Install-Module -Name VSSetup -Scope AllUsers
    }

    Import-Module -Name VSSetup -Scope Local
}

if ((Get-VSSetupInstance).InstallationVersion -ge "16.0") {
    Write-Host "Found instance of VS $($Version) - Skipping install"
    -Join ("Product Name".PadRight(20), ": ", (Get-VSSetupInstance).DisplayName, "`n", "InstallationPath".PadRight(20), ": ", (Get-VSSetupInstance).InstallationPath)
} else {
    Write-Host "Downloading VS setup bootstrapper"
    $toolsDir = (Join-Path "$(Split-Path -parent $MyInvocation.MyCommand.Definition)" 'vs')
    $vsPath = Join-Path "$toolsDir" "\vs_$($Sku).exe"
    New-Item -Path $toolsDir -ItemType directory -Force
    
    $vsVersion=switch ($Version) {
        2022 {"17"; break;}
        2019 {"16"; break;}
        default{"17"}
    }
    $url="https://aka.ms/vs/$($vsVersion)/release/vs_$($Sku).exe"
    (New-Object System.Net.WebClient).DownloadFile($url, "$vsPath")
    
    Write-Host "Installing VS $($Version) with Base Workloads"
    $programFilesFolder=(&{if ($Version -gt 2019) {${env:ProgramFiles}} else {${env:ProgramFiles(x86)}}})

    $commandArgs = @("--installPath `"$(Join-Path $programFilesFolder `"Microsoft Visual Studio\$($Version)\$($Sku)`")`"")
    $commandArgs += "--add Microsoft.VisualStudio.Workload.CoreEditor;includeRecommended"
    $commandArgs += "--add Microsoft.VisualStudio.Workload.Data;includeRecommended"
    #$commandArgs += "--add Microsoft.VisualStudio.Component.SQL.SSDT;includeRecommended"
    $commandArgs += "--add Microsoft.VisualStudio.Workload.ManagedDesktop;includeRecommended"
    $commandArgs += "--add Microsoft.VisualStudio.Workload.NetCoreTools;includeRecommended"
    $commandArgs += "--add Microsoft.VisualStudio.Workload.NetWeb;includeRecommended"
    $commandArgs += "--add Microsoft.VisualStudio.Workload.Azure;includeRecommended"
    $commandArgs += "--add Microsoft.VisualStudio.Workload.NativeDesktop;includeRecommended"
    $commandArgs += "--add Microsoft.VisualStudio.Workload.VisualStudioExtension;includeRecommended"
    $commandArgs += "--add Microsoft.Net.Component.4.6.1.TargetingPack"
    $commandArgs += "--add Microsoft.Net.Component.4.6.2.TargetingPack"
    $commandArgs += "--add Microsoft.Net.Component.4.7.TargetingPack"
    $commandArgs += "--add Microsoft.Net.Component.4.7.1.TargetingPack"
    $commandArgs += "--add Microsoft.Net.ComponentGroup.4.8.DeveloperTools"
    $commandArgs += "--add Microsoft.VisualStudio.ComponentGroup.ArchitectureTools.Managed"
    $commandArgs += "--add Microsoft.VisualStudio.Component.TestTools.WebLoadTest"
    $commandArgs += "--passive"
    $commandArgs += "--norestart"
    $commandArgs += "--wait"

    $p=$null
    try {
        $p = Start-Process -FilePath $vsPath -ArgumentList $commandArgs -PassThru -Wait
        if ($null -ne $p -and ($p.ExitCode -in @(0, 3010))) {
            Write-Host "VS $($Version) ($($Sku)) installation completed successfully" -ForegroundColor Green
        } else {
            Write-Error (-Join("VS $($Version) ($($Sku)) installation failed ", $p.ExitCode))
        }
    } finally {
        if ($null -ne $p) {
            $p.Dispose()
        }
    }
}
