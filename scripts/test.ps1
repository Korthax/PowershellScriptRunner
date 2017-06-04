[CmdletBinding(PositionalBinding=$false)]
Param(
    [Parameter(Position=0,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$One,
    [Parameter(Mandatory=$false,ValueFromRemainingArguments=$true)]
    [string[]]$ScriptArgs
)

Write-Host $One
Write-Host $ScriptArgs