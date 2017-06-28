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
    $ModuleDir = "$RootDir\Modules\"
    $ModulePath = "$ModuleDir\$Name"
    if (![System.IO.Path]::IsPathRooted($ScriptDir)) {
        $ScriptDir = [System.IO.Path]::GetFullPath((Join-Path $RootDir $ScriptDir))
    }

    Function WriteStartAction([string] $message) {
        Write-Host -ForegroundColor Cyan $message -NoNewline
    }

    Function WriteEndAction([bool] $success= $true) {
        if($success) {
            Write-Host -ForegroundColor Green "done"
        }
        else {
            Write-Host -ForegroundColor Yellow "skipped"
        }
    }
}
Process {
    WriteStartAction "Creating environment variables..."
    [Environment]::SetEnvironmentVariable("$($Name.ToUpper())_ROOT", $RootDir, "User")
    [Environment]::SetEnvironmentVariable("$($Name.ToUpper())_SCRIPTS", $ScriptDir, "User")
    WriteEndAction

    WriteStartAction "Registering module path..."
    [string] $psModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
    if ($psModulePath -and !($psModulePath.Contains($ModuleDir))) {
        $psModulePath += ";$ModuleDir"
        [Environment]::SetEnvironmentVariable("PSModulePath", $psModulePath)
        WriteEndAction
    }
    else {
        WriteEndAction $False
    }
}