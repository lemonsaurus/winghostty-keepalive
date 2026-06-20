# winghostty-keepalive

> [!WARNING]
> This is a dumb little workaround for a winghostty repaint bug.
> I'm using it until [wintty](https://github.com/deblasis/wintty) is ready.
> If you're from the future, lucky you, you probably don't need this.

I love ghostty, but Windows support is still a whole thing, so I'm running
[winghostty](https://github.com/amanthanvi/winghostty) for now.

It's mostly fine! but sometimes it stops repainting while a TUI is printing
output. The buffer keeps updating, the screen just sits there like an idiot
until I press a key or move the mouse.

So this is my tiny poking stick.

It finds `winghostty.exe`, walks its windows, calls `InvalidateRect`, sleeps
100ms, and does it again forever. That's the whole program.

## Build

Requires Zig 0.15.x.

```sh
zig build-exe main.zig -target x86_64-windows-gnu -O ReleaseSmall \
    -fsingle-threaded --subsystem windows
```

That gives you `main.exe`, about 4 KB, which is very funny considering the
PowerShell version used like 100 MB. fuck right off. I wrote about that whole
mess [over here](https://www.lemonsaur.us/blog/i-wrote-a-100mb-autoclicker).

## Install

Copy `main.exe` somewhere and put a shortcut in `shell:startup`.

Run it by hand:

```powershell
Start-Process C:\path\to\winghostty-keepalive.exe
```

Kill it:

```powershell
Stop-Process -Name winghostty-keepalive
```

No fake input, no hooks, no admin rights. Just poking a window until it
remembers to paint.
