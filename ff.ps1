function Get-FuzzyScore {
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [Parameter(Mandatory)]
        [string]$Pattern
    )

    $text = $Text.ToLower()
    $pattern = $Pattern.ToLower()

    $score = 0
    $lastMatch = -1

    foreach ($c in $pattern.ToCharArray()) {

        $found = $false

        for ($i = $lastMatch + 1; $i -lt $text.Length; $i++) {

            if ($text[$i] -eq $c) {

                # Base score
                $score += 1

                # Consecutive bonus
                if ($i -eq ($lastMatch + 1)) {
                    $score += 10
                }

                # Beginning of string
                if ($i -eq 0) {
                    $score += 20
                }

                # Word boundary
                if ($i -gt 0 -and $text[$i-1] -match '[\\/_\-. ]') {
                    $score += 15
                }

                # CamelCase bonus
                if ($i -gt 0 -and $Text[$i] -cmatch '[A-Z]') {
                    $score += 8
                }

                # Gap penalty
                if ($lastMatch -ge 0) {
                    $score -= ($i - $lastMatch - 1)
                }

                $lastMatch = $i
                $found = $true
                break
            }
        }

        if (-not $found) {
            return -1
        }
    }

    # Shorter names rank higher
    $score -= ($text.Length - $pattern.Length) * 0.1

    return [Math]::Round($score,2)
}


function fff {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Pattern,

        [Parameter(Position = 1)]
        [string]$Path = (Get-Location).Path,

        [Alias("R")]
        [switch]$Recursive
    )

    $scannedFiles = Get-ChildItem -Path $Path -File -Recurse:$Recursive -ErrorAction SilentlyContinue

    $matchedFiles = $scannedFiles |
        ForEach-Object {
            $score = Get-FuzzyScore $_.Name $Pattern

            if ($score -ge 0) {
                [PSCustomObject]@{
                    Score = $score
                    File  = $_
                }
            }
        } |
        Sort-Object Score -Descending

    if (-not $matchedFiles) {
        Write-Host "no matching files found with '$Pattern'" -ForegroundColor Yellow
        Write-Host "scanned files: $($scannedFiles.Count)"
        return
    }

    $matchedFiles | ForEach-Object {
        Write-Output $_.File.FullName
    }

    Write-Host "matched files : $($matchedFiles.Count) / $($scannedFiles.Count)" -ForegroundColor Cyan
}
function fff1 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Pattern,

        [Parameter(Position = 1)]
        [string]$Path = (Get-Location).Path,

        [Alias("R")]
        [switch]$Recursive
    )

    Get-ChildItem -Path $Path -File -Recurse:$Recursive -ErrorAction SilentlyContinue |
        ForEach-Object {
            $score = Get-FuzzyScore $_.Name $Pattern

            if ($score -ge 0) {
                [PSCustomObject]@{
                    Score = $score
                    Name  = $_.Name
                    File  = $_.FullName
                }
            }
        } |
        Sort-Object Score -Descending |
        Format-Table Score, Name, File -AutoSize
}


















function ff1 {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$Path = (Get-Location).Path,

        [switch]$Recursive
    )

    Push-Location $Path
    try {
        if ($Recursive) {
            where.exe /R . "*$Name*"
        }
        else {
            Get-ChildItem -File -Filter "*$Name*" |
                Select-Object -ExpandProperty FullName
        }
    }
    finally {
        Pop-Location
    }
}