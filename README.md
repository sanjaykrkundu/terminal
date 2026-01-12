# terminal

Windows :
https://learn.microsoft.com/en-us/windows/terminal



    $reset = "$([char]27)[0m"
    $esc = ([char]27)
    
    $rgb = "${esc}[38;2;69;241;194m"
    $blue = "${esc}[38;2;23;3;252m"
    $cyan = "${esc}[38;2;69;241;194m"

    // <<escape char>>[<<foreground(38)|background(48)>>;<<color mode(2 - TRUE RGB 24bit | 5 - 256 color)>>;<<R>>;<<G>>;<<B>>;<<apply(m)|remove(0m)>>
    

    
