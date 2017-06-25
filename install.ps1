[CmdletBinding()]
Param(
    [Parameter(Position=0, Mandatory=$true)]
    [string] $Name,
    [Parameter(Position=1, Mandatory=$true)]
    [ValidateScript({
        if(Test-Path $_) {
            return $true
        }

        throw "Invalid directory '$_''"
    })]
    [string]$Root,
    [Parameter(Position=2, Mandatory=$true)]
    [ValidateScript({
        if([System.IO.Path]::IsPathRooted($_)) {
            if(Test-Path "$_") {
                return $true
            }

            throw "Invalid directory '$_'"
        } elseif(Test-Path (Join-Path $Root $_)) {
            return $true
        } else {
            throw "Invalid directory '$(Join-Path $Root $_)'"
        }
    })]
    [string]$Scripts
)
Begin {
    Function CreateEnvironmentVariable([string] $name, [string] $value) {

    }
    Function CreateEnvironmentVariable([string] $name, [string] $value) {
        
    }
}
Process {
    $Root = [System.IO.Path]::GetFullPath($Root)
    $modulePath = "$Root/modules/$name"
    if(![System.IO.Path]::IsPathRooted($Scripts)) {
        $Scripts = [System.IO.Path]::GetFullPath((Join-Path $Root $Scripts))
    }

    Write-Host -ForegroundColor Cyan "Creating module directory..." -NoNewline
    New-Item -ErrorAction Ignore -ItemType directory -Path "$Root/modules/$Name" | Out-Null
    Write-Host -ForegroundColor Green "done"

    Write-Host -ForegroundColor Cyan "Writing module file..." -NoNewline
    [string] $proxi = Get-Content ".\proxi.psm1" | Out-String
    $proxi.Replace("Proxi", $Name).Replace("PROXI", $Name.ToUpper()) | Out-File "$Root/modules/$Name/$Name.psm1"
    Write-Host -ForegroundColor Green "done"

    Write-Host -ForegroundColor Cyan "Creating environment variables..." -NoNewline
    [Environment]::SetEnvironmentVariable("$($Name.ToUpper())_ROOT", $Root, "User")
    [Environment]::SetEnvironmentVariable("$($Name.ToUpper())_SCRIPTS", $Scripts, "User")
    Write-Host -ForegroundColor Green "done"

    Write-Host -ForegroundColor Cyan "Registering module path..." -NoNewline
    $psModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
    if(!$psModulePath.Contains($modulePath)) {
        $psModulePath += ";$modulePath"
        [Environment]::SetEnvironmentVariable("PSModulePath", $psModulePath)
    }
    Write-Host -ForegroundColor Green "done"
}