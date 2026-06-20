const std = @import("std");
const win = std.os.windows;

const HWND = win.HWND;
const BOOL = win.BOOL;
const DWORD = win.DWORD;
const LPARAM = win.LPARAM;

extern "user32" fn InvalidateRect(hWnd: ?HWND, lpRect: ?*const anyopaque, bErase: BOOL) callconv(.winapi) BOOL;
extern "user32" fn EnumWindows(lpEnumFunc: *const fn (HWND, LPARAM) callconv(.winapi) BOOL, lParam: LPARAM) callconv(.winapi) BOOL;
extern "kernel32" fn Sleep(dwMilliseconds: DWORD) callconv(.winapi) void;

fn enumTopCb(hwnd: HWND, _: LPARAM) callconv(.winapi) BOOL {
    _ = InvalidateRect(hwnd, null, 0);
    return 1;
}

pub export fn wWinMain(
    _: ?win.HINSTANCE,
    _: ?win.HINSTANCE,
    _: ?win.LPWSTR,
    _: c_int,
) callconv(.winapi) c_int {
    while (true) {
        _ = EnumWindows(&enumTopCb, 0);
        Sleep(100);
    }
}
