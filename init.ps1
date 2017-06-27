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
    [string]$RootDir,
    [Parameter(Position = 2, Mandatory = $true)]
    [ValidateScript( {
            if ([System.IO.Path]::IsPathRooted($_)) {
                if (Test-Path "$_") {
                    return $true
                }

                throw "Invalid directory '$_'"
            }
            elseif (Test-Path (Join-Path $RooRootDirt $_)) {
                return $true
            }
            else {
                throw "Invalid directory '$(Join-Path $RootDir $_)'"
            }
        })]
    [string]$ScriptDir
)
Begin {
    $RootDir = [System.IO.Path]::GetFullPath($RootDir)
    $ModulePath = "$RootDir/Modules/$Name"
    if (![System.IO.Path]::IsPathRooted($ScriptDir)) {
        $ScriptDir = [System.IO.Path]::GetFullPath((Join-Path $RootDir $ScriptDir))
    }
}
Process {
    Write-Host -ForegroundColor Cyan "Creating environment variables..." -NoNewline
    [Environment]::SetEnvironmentVariable("$($Name.ToUpper())_ROOT", $RootDir, "User")
    [Environment]::SetEnvironmentVariable("$($Name.ToUpper())_SCRIPTS", $ScriptDir, "User")
    Write-Host -ForegroundColor Green "done"

    Write-Host -ForegroundColor Cyan "Registering module path..." -NoNewline
    $psModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
    if (!$psModulePath.Contains($ModulePath)) {
        $psModulePath += ";$ModulePath"
        [Environment]::SetEnvironmentVariable("PSModulePath", $psModulePath)
        Write-Host -ForegroundColor Green "done"
    }
    else {
        Write-Host -ForegroundColor Yellow "skipped"
    }
}