[CmdletBinding()]
Param(
    [Parameter(Position=0,Mandatory=$true)]
    [string]$One,
    [Parameter(Position=1,Mandatory=$false)]
    [ValidateSet("Hi", "Bye")]
    [string]$Two
)

Write-Host $One
Write-Host $Two
Write-Host $Verbosity