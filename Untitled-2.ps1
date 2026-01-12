$global:PSSpecialChar = @{
    FullBlock        = ([char]0x2588)
    LightShade       = ([char]0x2591)
    MediumShade      = ([char]0x2592)
    DarkShade        = ([char]0x2593)
    BlackSquare      = ([char]0x25A0)
    WhiteSquare      = ([char]0x25A1)
    BlackSmallSquare = ([char]0x25AA)
    WhiteSmallSquare = ([char]0x25AB)
    UpTriangle       = ([char]0x25B2)
    DownTriangle     = ([char]0x25BC)
    Lozenge          = ([char]0x25CA)
    WhiteCircle      = ([char]0x25CB)
    BlackCircle      = ([char]0x25CF)
    WhiteFace        = ([char]0x263A)
    BlackFace        = ([char]0x263B)
    SixPointStar     = ([char]0x2736)
    Diamond          = ([char]0x2666)
    Club             = ([char]0x2663)
    Heart            = ([char]0x2665)
    Spade            = ([char]0x2660)
    Section          = ([char]0x00A7)
    RightPointer     = ([char]0x25BA)
    LeftPointer      = ([char]0x25C4)
    BlackRectangle   = ([char]0x25AC)
    Check            = ([char]0xF00c)
}

# Write-Host ("'" + $PSSpecialChar.FullBlock + "'")
# Write-Host ("'" + $PSSpecialChar.LightShade + "'")
# Write-Host ("'" + $PSSpecialChar.MediumShade + "'")
# Write-Host ("'" + $PSSpecialChar.DarkShade + "'")
# Write-Host ("'" + $PSSpecialChar.BlackSquare + "'")
# Write-Host ("'" + $PSSpecialChar.WhiteSquare + "'")
# Write-Host ("'" + $PSSpecialChar.BlackSmallSquare + "'")
# Write-Host ("'" + $PSSpecialChar.WhiteSmallSquare + "'")
# Write-Host ("'" + $PSSpecialChar.UpTriangle + "'")
# Write-Host ("'" + $PSSpecialChar.DownTriangle + "'")
# Write-Host ("'" + $PSSpecialChar.Lozenge + "'")
# Write-Host ("'" + $PSSpecialChar.WhiteCircle + "'")
# Write-Host ("'" + $PSSpecialChar.BlackCircle + "'")
# Write-Host ("'" + $PSSpecialChar.WhiteFace + "'")
# Write-Host ("'" + $PSSpecialChar.BlackFace + "'")
# Write-Host ("'" + $PSSpecialChar.SixPointStar + "'")
# Write-Host ("'" + $PSSpecialChar.Diamond + "'")
# Write-Host ("'" + $PSSpecialChar.Club + "'")
# Write-Host ("'" + $PSSpecialChar.Heart + "'")
# Write-Host ("'" + $PSSpecialChar.Spade + "'")
# Write-Host ("'" + $PSSpecialChar.Section + "'")
# Write-Host ("'" + $PSSpecialChar.RightPointer + "'")
# Write-Host ("'" + $PSSpecialChar.LeftPointer + "'")
# Write-Host ("'" + $PSSpecialChar.BlackRectangle + "'")


function moveWithCount {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    $items = Get-ChildItem $Source -Force -ErrorAction SilentlyContinue
    if (-not $items) {
        Write-Host 'mv: no matching files found' -ForegroundColor Yellow
        return
    }

    $MovedItems = Move-Item -Path $Source -Destination $Destination -Force -PassThru
    $count = ($MovedItems | Measure-Object).Count
    Write-Host ($PSSpecialChar.Check + " " + $count.ToString() + ' item(s) moved ') -ForegroundColor Green
}

function grepSearch {
    param(
        [Parameter(Position = 0)]
        $regex,

        [Parameter(Position = 1)]
        $dir,

        [Parameter(ValueFromRemainingArguments=$true)]
        $args
    )

    Write-Output $args

    $recurse = $false
    if ($args -match '(^|\s)-?r(\s|$)') { $recurse = $true }

    if ($dir) {
        Get-ChildItem -Path $dir -Recurse:$recurse -File | Select-String $regex
        return
    }

    $input | Select-String $regex
}

function lll {
    param(
        [string]$Path = "."
    )

    Get-ChildItem -Path $Path -Force |
        Sort-Object @{ Expression = { -not $_.PSIsContainer } }, Name |
        Format-Table `
            @{ Name = "Size"; Expression = {
                if ($_.PSIsContainer) {
                    "<DIR>"
                }
                else {
                    $s = $_.Length
                    if ($s -ge 1GB) { "{0:N2} GB" -f ($s / 1GB) }
                    elseif ($s -ge 1MB) { "{0:N2} MB" -f ($s / 1MB) }
                    elseif ($s -ge 1KB) { "{0:N2} KB" -f ($s / 1KB) }
                    else { "$s B" }
                }
            }},
            Name -AutoSize
}

function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}

# function prompt { "Hello".PadRight([Console]::WindowWidth - 5) + "World`n> " }

# function prompt {
#     $reset = "$([char]27)[0m"
#     $esc = ([char]27)
    
#     $rgb = "${esc}[38;2;69;241;194m"
#     $blue = "${esc}[38;2;23;3;252m"
#     $cyan = "${esc}[38;2;69;241;194m"
#     # "$([char]27)[${rgb}mHello$([char]27)[0m".PadRight([Console]::WindowWidth - 5) +  "$([char]27)[${rgb}mWorld$([char]27)[0m`n> "
#     # Write-Host "> " -ForegroundColor $c


#     Write-Host "${cyan}Hello ${blue}World$reset" -NoNewline
# }


Set-Alias -Name mv -Value moveWithCount
