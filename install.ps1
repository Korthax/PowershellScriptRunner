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
    [string]$RootDir
)
Begin {
    $RootDir = [System.IO.Path]::GetFullPath($RootDir)
    $ModulePath = "$RootDir/Modules/$Name"
}
Process {
    Write-Host -ForegroundColor Cyan "Creating module directory..." -NoNewline
    New-Item -ErrorAction Ignore -ItemType directory -Path $ModulePath | Out-Null
    Write-Host -ForegroundColor Green "done"

    Write-Host -ForegroundColor Cyan "Writing files..." -NoNewline
    [string] $proxiModule = Get-Content ".\proxi.psm1" | Out-String
    [string] $proxiDefinition = Get-Content ".\proxi.psm1" | Out-String
    [string] $tabExpansion = Get-Content ".\ProxiTabExpansion.ps1" | Out-String
    $proxiModule.Replace("PROXI", $Name.ToUpper()).Replace("proxi", $Name.ToLower()).Replace("Proxi", $Name) | Out-File "$ModulePath/$Name.psm1"
    $proxiDefinition.Replace("PROXI", $Name.ToUpper()).Replace("proxi", $Name.ToLower()).Replace("Proxi", $Name) | Out-File "$ModulePath/$Name.psd1"
    $tabExpansion.Replace("PROXI", $Name.ToUpper()).Replace("proxi", $Name.ToLower()).Replace("Proxi", $Name) | Out-File "$ModulePath/$($Name)TabExpansion.psm1"
    Write-Host -ForegroundColor Green "done"
}