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

    Function Compile([string] $content) {
        return $content.Replace("PROXI", $Name.ToUpper()).Replace("proxi", $Name.ToLower()).Replace("Proxi", $Name)
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
    WriteStartAction "Creating module directory..."
    New-Item -ErrorAction Ignore -ItemType directory -Path $ModulePath | Out-Null
    WriteEndAction

    WriteStartAction "Writing files..."
    Compile (Get-Content ".\proxi.psm1" | Out-String) | Out-File "$ModulePath/$Name.psm1"
    Compile (Get-Content ".\proxi.psd1" | Out-String) | Out-File "$ModulePath/$Name.psd1"
    Compile (Get-Content ".\ProxiTabExpansion.ps1" | Out-String) | Out-File "$ModulePath/$($Name)TabExpansion.psm1"
    Compile (Get-Content ".\register.ps1" | Out-String) | Out-File "$ModulePath/register.psm1"
    WriteEndAction
}