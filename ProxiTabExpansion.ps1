function ExpandScripts([string] $lastBlock) {
    return Get-ChildItem -Path "$ENV:PROXI_SCRIPTS" -Filter "$($lastBlock)*.ps1" -ErrorAction SilentlyContinue | Foreach-Object { $_.BaseName } 
}

function DefaultExpansion([string] $line, [string] $lastWord) {
    if (Test-Path Function:\TabExpansionBackup) {
        return TabExpansionBackup $line $lastWord
    }

    return @()
}

if (Test-Path Function:\TabExpansion) {
    Rename-Item Function:\TabExpansion TabExpansionBackup
}

function TabExpansion($line, $lastWord) {
    $lastBlock = [regex]::Split($line, '[|;]')[-1].TrimStart()

    if($lastBlock.StartsWith("-")) {
        return DefaultExpansion $line $lastWord
    }

    switch -regex ($lastBlock) {
        'proxi -Script (\S*)$' {
            return ExpandScripts($matches[1])
        }
        'proxi (\S*)$' {
            return ExpandScripts($matches[1])
        }
        default {
            return DefaultExpansion $line $lastWord
        }
    }
}
