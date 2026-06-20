const std = @import("std");
const win = std.os.windows;

const BOOL = win.BOOL;
const DWORD = win.DWORD;

extern "user32" fn InvalidateRect(hWnd: ?win.HWND, lpRect: ?*const anyopaque, bErase: BOOL) callconv(.winapi) BOOL;
extern "kernel32" fn Sleep(dwMilliseconds: DWORD) callconv(.winapi) void;

pub export fn wWinMain(
    _: ?win.HINSTANCE,
    _: ?win.HINSTANCE,
    _: ?win.LPWSTR,
    _: c_int,
) callconv(.winapi) c_int {
    while (true) {
        _ = InvalidateRect(null, null, 0);
        Sleep(100);
    }
}
