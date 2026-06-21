# winghostty-keepalive

> [!WARNING]
> This is a dumb little workaround for a winghostty repaint bug.
> I'm using it until [wintty](https://github.com/deblasis/wintty) is ready.
> If you're from the future (hiii!👋), you probably don't need this.

I love ghostty, but Windows support is still a whole thing, so I'm running
[winghostty](https://github.com/amanthanvi/winghostty) for now.

Sometimes it stops repainting while a TUI (like a log tail) is still printing
output. The screen just sits there like an idiot
until I press a key or move the mouse.

So like any good engineer would, I wrote a script to poke it with a stick.

It just... finds `winghostty.exe`, calls `InvalidateRect`, sleeps
100ms, and does it again, for ever and ever and ever.

## Build

```sh
zig build-exe main.zig -target x86_64-windows-gnu -O ReleaseSmall \
    -fsingle-threaded --subsystem windows
```

That gives you an executable that's about 4 KB, which is very funny considering the
PowerShell version was like 100 MB. I wrote about that whole
mess [over here](https://www.lemonsaur.us/blog/i-wrote-a-100mb-autoclicker).
