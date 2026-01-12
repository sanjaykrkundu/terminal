# terminal

Windows Terminal Guide:
https://learn.microsoft.com/en-us/windows/terminal

Oh My Posh Templates :
- https://ohmyposh.dev/docs/themes
- https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/amro.omp.json

```
    $reset = "$([char]27)[0m"
    $esc = ([char]27)
    
    $rgb = "${esc}[38;2;69;241;194m"
    $blue = "${esc}[38;2;23;3;252m"
    $cyan = "${esc}[38;2;69;241;194m"
    // <<escape char>>[<<foreground(38)|background(48)>>;<<color mode(2 - TRUE RGB 24bit | 5 - 256 color)>>;<<R>>;<<G>>;<<B>>;<<apply(m)|remove(0m)>>

    //example
    Write-Host "${cyan}Hello ${blue}World$reset" -NoNewline
```
```
{
  "git": {
    "url": "https://github.com/login",
    "username" : "xxxxx@gmail.com",
    "loadDelay": 6,
    "focusTabCount" : 0
  },
  "test": {
    "url": "https://www.aaaaaaaaaaaaaa.com/login/",
    "username" : "user",
    "loadDelay": 8,
    "focusTabCount" : 7
  },
 "gmail": {
    "url": "https://accounts.google.com",
    "username": "user@gmail.com",
    "loadDelay": 8,
    "steps": [
      { "type": "wait", "ms": 3000 },
      { "type": "tab", "count": 2 },
      { "type": "text", "value": "{username}" },
      { "type": "tab", "count": 1 },
      { "type": "text", "value": "{password}" },
      { "type": "key", "value": "{ENTER}" }
    ]
  }
}
```
