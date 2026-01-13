$themeFolder = Join-Path -Path (Split-Path $PROFILE) -ChildPath "themes"
# $themeFile = Join-Path -Path $themeFolder -ChildPath "amro.omp.json"
# $themeFile = Join-Path -Path $themeFolder -ChildPath "agnoster.minimal.omp.json"
# $themeFile = Join-Path -Path $themeFolder -ChildPath "agnosterplus.omp.json"
# $themeFile = Join-Path -Path $themeFolder -ChildPath "1_shell.omp.json"
$themeFile = Join-Path -Path $themeFolder -ChildPath "multiverse-neon.omp.json"

# These functions is used for setup, then deleted below
function Initialize-Theme {
    if (Test-Path $themeFile) {
        $global:theme = Get-Content -Raw $themeFile | ConvertFrom-Json
        # Write-Host "Applying $($global:theme.name) theme..." -ForegroundColor Cyan
        # Theme-Builder $($global:theme)
    }
    else {
        Write-Warning "Theme file not found at $themeFile"
    }
}

$global:session = [PSCustomObject]@{
    UserName     = $env:USERNAME
    HostName     = $env:COMPUTERNAME
    SystemColors = [PSCustomObject]@{
        Background = $Host.UI.RawUI.BackgroundColor
        Foreground = $Host.UI.RawUI.ForegroundColor
    }
}

function Initialize-Values {
    $global:path = [PSCustomObject]@{
        Folder = (Get-Location).Path | Split-Path -Leaf
        Path   = (Get-Location).Path
    }
}


function Is-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-AnsiColor {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Hex,
        [int]$Layer
    )
    try {

        $cleanHex = $Hex.Trim('#')
        if ($cleanHex.length -eq 3) {
            $cleanHex = "$($cleanHex[0])$($cleanHex[0])$($cleanHex[1])$($cleanHex[1])$($cleanHex[2])$($cleanHex[2])"
        }
        if ($cleanHex.length -ne 6) { throw "Invalid Hex length" }
        $r = [System.Convert]::ToInt32($cleanHex.Substring(0, 2), 16)
        $g = [System.Convert]::ToInt32($cleanHex.Substring(2, 2), 16)
        $b = [System.Convert]::ToInt32($cleanHex.Substring(4, 2), 16)
        return "$([char]27)[$($Layer);2;$r;$g;$($b)m"
    }
    catch {
        # Write-Host $Hex $Layer
        Write-Error "here"
        return ""
    }
}

function Theme-Builder {
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$theme
    )

    $rprompt = @{}
    for ($i = 0; $i -lt $theme.blocks.Count; $i++) {
        $block = $theme.blocks[$i]

        $isLast = ($i -eq ($theme.blocks.Count - 1))
        $blockText = Theme-Block-Builder -block $block

        # Write-Host $blockText.normalOutput.length $i $theme.blocks.Count $isLast

        if ($block.type -eq "rprompt" || $block.alignment -eq "right") {
            $rprompt = $blockText
        } elseif ($block.type -eq "prompt" && $block.alignment -eq "left") {
            # Write-Host $Pad $blockText.normalOutput.length $rprompt.normalOutput.length $Width -NoNewline
            if ($blockText.normalOutput.length -gt 0) {
                Write-Host $blockText.coloredOutput -NoNewline
            }
            if ($rprompt.normalOutput.length -gt 0) {
                $Width = $Host.UI.RawUI.WindowSize.Width
                $Pad = $Width - $blockText.normalOutput.length - $rprompt.normalOutput.length
                Write-Host (" " * $Pad) -NoNewline 
                Write-Host $rprompt.normalOutput
            } elseif ($isLast) {
                if($rprompt.normalOutput.length -eq 0) {
                    Write-Host $rprompt.normalOutput -NoNewline
                } else {
                    Write-Host $rprompt.normalOutput
                }
            } elseif ($blockText.normalOutput.length -gt 0){
                Write-Host $rprompt.normalOutput
            }

            $rprompt = ""
        }
    }

    if ($rprompt.normalOutput) {
        Write-Host $rprompt "---"
    }
    if ($theme.console_title_template) {
        $Host.UI.RawUI.WindowTitle = $theme.console_title_template -replace '\{\{\s*\.Folder\s*\}\}', $global:path.Folder
    }
}

function Theme-Block-Builder {
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$block
    )

    $segmentText = [PSCustomObject]@{
        coloredOutput = ""
        normalOutput  = ""
    }
    $lastForeGround = $global:session.SystemColors.Foreground
    $lastBackGround = $global:session.SystemColors.Background
    foreach ($segment in $block.segments) {
        $data = (Theme-Segment-Builder -segment $segment -lastForeGround $lastForeGround -lastBackGround $lastBackGround)
        $segmentText.normalOutput += $data.normalOutput
        $segmentText.coloredOutput += $data.coloredOutput
        if ($segment.foreground) {
            $lastForeGround = $global:session.SystemColors.Foreground
        }
        else {
            # $lastForeGround = $global:session.SystemColors.Foreground
        }
        if ($segment.background) {
            $lastBackGround = $global:session.SystemColors.Background
        }
        else {
            # $lastBackGround = $global:session.SystemColors.Background
        }
    }

    # Write-Host ";"$segmentText";"
    # Write-Host "Segment "  $segmentText.length $segmentText.coloredOutput.length, $segmentText.normalOutput.length

    # return $segmentText.normalOutput
    return $segmentText
}

function Theme-Segment-Builder {
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$segment,
        $lastForeGround,
        $lastBackGround
    )
    $reset = "$([char]27)[0m"
    $foreground = ""
    $background = ""


    if ($segment.background) {
        $background = Get-AnsiColor -Hex $segment.background -Layer 48
    }
    if ($segment.foreground) {
        $foreground = Get-AnsiColor -Hex $segment.foreground -Layer 38
    }

    $output = $segment.template

    switch ($segment.type) {
        # done
        "session" {
            if ($output) {
                $output = $output -replace '\{\{\s*\.UserName\s*\}\}', $global:session.UserName
                $output = $output -replace '\{\{\s*\.HostName\s*\}\}', $global:session.HostName
            }
        }
        # done
        "path" {
            if ($output) {
                $output = $output -replace '\{\{\s*\.Path\s*\}\}', $global:path.Path
                $output = $output -replace '\{\{\s*\.Folder\s*\}\}', $global:path.Folder
            }
        }
        # done
        "root" {
            if (!(Is-Admin)) {
                $output = ""
            }
        }
        # "status" {
        #     $output = "status"
        # }
        "text" {
        }
        "time" {
            $output = "time"
        }
        Default {
            $output = ""
        }
    }

    # Write-Host $output $output.Length $output.length

    if ($output) {
        $symbolStart = ""
        $symbolEnd = ""
        switch ($segment.style) {
            "powerline" {
                if ($segment.powerline_symbol) { $symbolStart = $segment.powerline_symbol }
            }
            "diamond" {
                if ($segment.leading_diamond) { $symbolStart = $segment.leading_diamond }
                if ($segment.trailing_diamond) { $symbolEnd = $segment.trailing_diamond }
            }

            Default {}
        }

        $coloredOutput = ""
        $normalOutput = ""
        if ($symbolStart) {
            $normalOutput += $symbolStart
        }
        $normalOutput += "$output"
        $coloredOutput += "$foreground$background$output$reset"
        if ($symbolEnd) {
            $normalOutput += $symbolEnd
        }

        # Write-Host $normalOutput

        return [PSCustomObject]@{
            normalOutput  = $normalOutput
            coloredOutput = $coloredOutput
        }
    }
}


# --- Execute ---
Clear-Host
Write-Host 'Welcome' -ForegroundColor DarkGreen
Initialize-Theme
function prompt {
    Initialize-Values
    Theme-Builder $global:theme
    Set-PSReadLineOption -ViModeIndicator Cursor
    # Cursor Shape,PowerShell Command (1 q, 3 q, 5 q)
    Write-Host -NoNewline "$([char]27)[3 q"
    return ' '
}


# --- Cleanup ---
# Deletes the setup function so it can't be called from the terminal
Remove-Item -Path Function:\Initialize-Theme


# [Enum]::GetValues([ConsoleColor]) | ForEach-Object {
#     $_
#     # Write-Host (" {0,-12} " -f $_) -ForegroundColor $_ -NoNewline
#     # Write-Host (" Background ") -BackgroundColor $_
# }



function admin {
    if ($args.Count -gt 0) {
        $argList = $args -join ' '
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    }
    else {
        Start-Process wt -Verb runAs
    }
}
