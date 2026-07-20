function log {
    <#
    .SYNOPSIS
        Filter logs from a file or from live adb logcat.

    .DESCRIPTION
        A single function for two inputs:
        1. Filters: uses .\filter.txt by default, or pass strings / another filter file path.
        2. Logs: pass a log file path, or omit it to read from adb logcat.

        Filter behavior:
        - Simple filter strings match anywhere in the log line.
        - Prefix a filter with '-' or '!' to remove matching lines.
        - Prefix a filter with '+' to explicitly include matching lines.

    .EXAMPLE
        log -Filter "error", "warning" -LogFile ".\app.log"

    .EXAMPLE
        log -Filter ".\filter.txt" -LogFile ".\app.log"

    .EXAMPLE
        log -Filter "ActivityManager", "System.err"

    .EXAMPLE
        log

    .EXAMPLE
        log -LogFile ".\app.log"

    .EXAMPLE
        log -LogFile ".\app.log" -Follow
    #>
    param(
        [Parameter(Position = 0)]
        [string[]]$Filter = @(".\filter.txt"),

        [Parameter(Position = 1)]
        [string]$LogFile,

        [switch]$Regex,

        [switch]$CaseSensitive,

        [switch]$Follow,

        [string[]]$AdbArgs = @("logcat")
    )

    function ConvertTo-LogFilterRule {
        param([string[]]$Items)

        $rules = @()

        foreach ($item in $Items) {
            if ([string]::IsNullOrWhiteSpace($item)) {
                continue
            }

            $text = $item.Trim()

            if ($text.StartsWith("#")) {
                continue
            }

            $action = "MATCH"

            if ($text.StartsWith("-") -or $text.StartsWith("!")) {
                $action = "REMOVE"
                $text = $text.Substring(1).Trim()
            }
            elseif ($text.StartsWith("+")) {
                $text = $text.Substring(1).Trim()
            }

            if ([string]::IsNullOrWhiteSpace($text)) {
                continue
            }

            $rules += [PSCustomObject]@{
                Action = $action
                Text   = $text
            }
        }

        return $rules
    }

    function Test-LogText {
        param(
            [string]$Line,
            [string]$Text
        )

        if ($Regex) {
            $options = [System.Text.RegularExpressions.RegexOptions]::None
            if (-not $CaseSensitive) {
                $options = $options -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
            }

            return [regex]::IsMatch($Line, $Text, $options)
        }

        if ($CaseSensitive) {
            return $Line.Contains($Text)
        }

        return ($Line.IndexOf($Text, [System.StringComparison]::OrdinalIgnoreCase) -ge 0)
    }

    function Write-FilteredLogLine {
        param(
            [string]$Line,
            [array]$Rules
        )

        foreach ($rule in $Rules.Where({ $_.Action -eq "REMOVE" })) {
            if (Test-LogText -Line $Line -Text $rule.Text) {
                return
            }
        }

        $matchRules = @($Rules.Where({ $_.Action -eq "MATCH" }))
        if ($matchRules.Count -eq 0) {
            Write-Host $Line
            return
        }

        foreach ($rule in $matchRules) {
            if (Test-LogText -Line $Line -Text $rule.Text) {
                Write-Host $Line
                return
            }
        }
    }

    $filterItems = @()

    if ($Filter.Count -eq 1 -and (Test-Path -LiteralPath $Filter[0] -PathType Leaf)) {
        $filterItems = Get-Content -LiteralPath $Filter[0]
    }
    else {
        $filterItems = $Filter
    }

    $rules = ConvertTo-LogFilterRule -Items $filterItems

    if ($LogFile) {
        if (-not (Test-Path -LiteralPath $LogFile -PathType Leaf)) {
            throw "Log file not found: $LogFile"
        }

        $getContentParams = @{
            LiteralPath = $LogFile
        }

        if ($Follow) {
            $getContentParams.Wait = $true
        }

        Get-Content @getContentParams | ForEach-Object {
            Write-FilteredLogLine -Line $_ -Rules $rules
        }

        return
    }

    & adb @AdbArgs | ForEach-Object {
        Write-FilteredLogLine -Line $_ -Rules $rules
    }
}
