[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string] $Name,
    [Parameter(Position = 1, Mandatory = $true)]
    [ValidateScript( {
            if (Test-Path $_) {
                return $true
            }

            throw "Invalid directory '$_''"
        })]
    [string]$Root,
    [Parameter(Position = 2, Mandatory = $true)]
    [ValidateScript( {
            if ([System.IO.Path]::IsPathRooted($_)) {
                if (Test-Path "$_") {
                    return $true
                }

                throw "Invalid directory '$_'"
            }
            elseif (Test-Path (Join-Path $Root $_)) {
                return $true
            }
            else {
                throw "Invalid directory '$(Join-Path $Root $_)'"
            }
        })]
    [string]$Scripts
)
Process {
    $Root = [System.IO.Path]::GetFullPath($Root)
    $modulePath = "$Root\modules"
    if (![System.IO.Path]::IsPathRooted($Scripts)) {
        $Scripts = [System.IO.Path]::GetFullPath((Join-Path $Root $Scripts))
    }

    Write-Host -ForegroundColor Magenta "Using Root: " -NoNewline
    Write-Host "$Root"

    Write-Host -ForegroundColor Magenta "Using Scripts: " -NoNewline
    Write-Host "$Scripts"

    Write-Host -ForegroundColor Magenta "Using ModulePath: " -NoNewline
    Write-Host "$modulePath"


    Write-Host -ForegroundColor Cyan "Creating module directory..." -NoNewline
    New-Item -ErrorAction Ignore -ItemType directory -Path "$Root/modules/$Name" | Out-Null
    Write-Host -ForegroundColor Green "done"

    Write-Host -ForegroundColor Cyan "Writing files..." -NoNewline
    [string] $proxiModule = Get-Content ".\proxi.psm1" | Out-String
    [string] $proxiDefinition = Get-Content ".\proxi.psm1" | Out-String
    [string] $tabExpansion = Get-Content ".\ProxiTabExpansion.ps1" | Out-String
    $proxiModule.Replace("PROXI", $Name.ToUpper()).Replace("proxi", $Name.ToLower()).Replace("Proxi", $Name) | Out-File "$Root/modules/$Name/$Name.psm1"
    $proxiDefinition.Replace("PROXI", $Name.ToUpper()).Replace("proxi", $Name.ToLower()).Replace("Proxi", $Name) | Out-File "$Root/modules/$Name/$Name.psd1"
    $tabExpansion.Replace("PROXI", $Name.ToUpper()).Replace("proxi", $Name.ToLower()).Replace("Proxi", $Name) | Out-File "$Root/modules/$Name/$($Name)TabExpansion.psm1"
    Write-Host -ForegroundColor Green "done"

    Write-Host -ForegroundColor Cyan "Creating environment variables..." -NoNewline
    [Environment]::SetEnvironmentVariable("$($Name.ToUpper())_ROOT", $Root, "User")
    [Environment]::SetEnvironmentVariable("$($Name.ToUpper())_SCRIPTS", $Scripts, "User")
    Write-Host -ForegroundColor Green "done"

    Write-Host -ForegroundColor Cyan "Registering module path..." -NoNewline
    $psModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
    if (!$psModulePath.Contains($modulePath)) {
        $psModulePath += ";$modulePath"
        [Environment]::SetEnvironmentVariable("PSModulePath", $psModulePath)
        Write-Host -ForegroundColor Green "done"
    }
    else {
        Write-Host -ForegroundColor Yellow "skipped"
    }
}