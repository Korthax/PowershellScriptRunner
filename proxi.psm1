function Proxi
{
    [CmdletBinding()]
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateScript({
            if(Test-Path "$($ENV:PROXI_SCRIPTS)/*" -Include "$_.ps1") {
                return $true
            }

            throw "Unknown script '$($ENV:PROXI_SCRIPTS)/$_.ps1'"
        })]
        [string]$Script,
        [Parameter(Mandatory=$false,ValueFromRemainingArguments=$true)]
        [string[]]$ScriptArgs
    )
    DynamicParam
    {
        if(!$Script) {
            return
        }

        $commonParameters = $("Verbose", "Debug", "ErrorAction", "ErrorVariable", "OutVariable", "OutBuffer", "WarningAction", "InformationAction", "WarningVariable", "InformationVariable", "PipelineVariable", "Script", "ScriptArgs")
        $runtimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        $scriptName = $Script.Replace(".ps1", "")
        $scriptToRun = Get-ChildItem -Path "$($ENV:PROXI_SCRIPTS)" -Filter "${scriptName}.ps1" -ErrorAction SilentlyContinue  | Select-Object -ExpandProperty FullName

        if(!$scriptToRun) {
            return
        }

        $command = Get-Command $scriptToRun
        foreach($parameter in $command.Parameters.Values) {
            if(!$parameter -or ($commonParameters -contains $parameter.Name) -or $runtimeParameterDictionary.ContainsKey($parameter.Name)) {
                continue
            }
            
            $valueFromRemainingArguments = $false
            foreach($attribute in $parameter.Attributes) {
                if($attribute.GetType() -eq [Parameter]) {
                    $valueFromRemainingArguments = $valueFromRemainingArguments -or $attribute.ValueFromRemainingArguments
                }
            }

            if($valueFromRemainingArguments) {
                continue
            }

            $runtimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($parameter.Name, $parameter.ParameterType, $parameter.Attributes)
            $runtimeParameterDictionary.Add($parameter.Name, $runtimeParameter)
        }

        return $runtimeParameterDictionary
    }
    Process
    {
        function BuildArgumentArray([System.Management.Automation.InvocationInfo] $function) {
            $arguments = "";

            if($function.BoundParameters) {
                foreach($arg in $function.BoundParameters.GetEnumerator()) {
                    if($arg.Key -eq "ScriptArgs" -or $arg.Key -eq "Script") {
                        continue
                    }

                    $arguments += "-$($arg.Key) $($arg.Value) "
                }
            }

            if($function.UnboundParameters) {
                foreach($arg in $function.UnboundParameters) {
                    $arguments += "$($arg.Value) "
                }
            }

            if($ScriptArgs) {
                $arguments += "$ScriptArgs"
            }

            return $arguments
        }

        $scriptToRun = Get-ChildItem -Path "$($ENV:PROXI_SCRIPTS)" -Filter "${Script}.ps1" -ErrorAction SilentlyContinue

        if(!$scriptToRun) {
            Write-Host -ForegroundColor Red "Script not found."
            return
        }

        $arguments = BuildArgumentArray $MyInvocation

        Write-Host -ForegroundColor Cyan "Running script: $($scriptToRun.FullName) $arguments"
        Invoke-Expression "& $($scriptToRun.FullName) $arguments"
    }
}

if (Get-Command Register-ArgumentCompleter -ea Ignore)
{
    Register-ArgumentCompleter -CommandName "Proxi" -ParameterName "Script" -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

        $targets = Get-ChildItem -Path "$($ENV:PROXI_SCRIPTS)" -Filter "*.ps1" -ErrorAction SilentlyContinue | Where-Object { $_.BaseName.ToString().StartsWith($wordToComplete) }
        
        foreach($target in $targets) {
            New-CompletionResult -CompletionText "$($target.BaseName)"
        }
    }
}

export-modulemember -function Proxi
