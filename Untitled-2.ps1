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

function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}


Set-Alias -Name mv -Value moveWithCount