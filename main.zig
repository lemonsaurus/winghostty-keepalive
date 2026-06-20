const std = @import("std");
const win = std.os.windows;

const HWND = win.HWND;
const BOOL = win.BOOL;
const DWORD = win.DWORD;
const LPARAM = win.LPARAM;

extern "user32" fn InvalidateRect(hWnd: ?HWND, lpRect: ?*const anyopaque, bErase: BOOL) callconv(.winapi) BOOL;
extern "user32" fn EnumWindows(lpEnumFunc: *const fn (HWND, LPARAM) callconv(.winapi) BOOL, lParam: LPARAM) callconv(.winapi) BOOL;
extern "user32" fn GetWindowThreadProcessId(hWnd: HWND, lpdwProcessId: *DWORD) callconv(.winapi) DWORD;
extern "kernel32" fn Sleep(dwMilliseconds: DWORD) callconv(.winapi) void;
extern "kernel32" fn CreateToolhelp32Snapshot(dwFlags: DWORD, th32ProcessID: DWORD) callconv(.winapi) win.HANDLE;
extern "kernel32" fn Process32FirstW(hSnapshot: win.HANDLE, lppe: *PROCESSENTRY32W) callconv(.winapi) BOOL;
extern "kernel32" fn Process32NextW(hSnapshot: win.HANDLE, lppe: *PROCESSENTRY32W) callconv(.winapi) BOOL;
extern "kernel32" fn CloseHandle(hObject: win.HANDLE) callconv(.winapi) BOOL;

const TH32CS_SNAPPROCESS: DWORD = 0x00000002;
const INVALID_HANDLE_VALUE: win.HANDLE = @ptrFromInt(@as(usize, @bitCast(@as(isize, -1))));

const PROCESSENTRY32W = extern struct {
    dwSize: DWORD,
    cntUsage: DWORD,
    th32ProcessID: DWORD,
    th32DefaultHeapID: usize,
    th32ModuleID: DWORD,
    cntThreads: DWORD,
    th32ParentProcessID: DWORD,
    pcPriClassBase: i32,
    dwFlags: DWORD,
    szExeFile: [260]u16,
};

const target_exe = std.unicode.utf8ToUtf16LeStringLiteral("winghostty.exe");
const interval_ms: DWORD = 100;
const max_pids = 16;

const State = struct {
    pids: [max_pids]DWORD,
    pid_count: usize,
};

var state: State = .{ .pids = undefined, .pid_count = 0 };

fn streqW(a: []const u16, b: []const u16) bool {
    if (a.len != b.len) return false;
    for (a, b) |x, y| {
        const lx = if (x >= 'A' and x <= 'Z') x + 32 else x;
        const ly = if (y >= 'A' and y <= 'Z') y + 32 else y;
        if (lx != ly) return false;
    }
    return true;
}

fn refreshTargetPids() void {
    state.pid_count = 0;
    const snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (@intFromPtr(snap) == @intFromPtr(INVALID_HANDLE_VALUE)) return;
    defer _ = CloseHandle(snap);

    var entry: PROCESSENTRY32W = std.mem.zeroes(PROCESSENTRY32W);
    entry.dwSize = @sizeOf(PROCESSENTRY32W);
    if (Process32FirstW(snap, &entry) == 0) return;

    while (true) {
        const name = entry.szExeFile;
        const len = std.mem.indexOfScalar(u16, &name, 0) orelse name.len;
        if (streqW(name[0..len], target_exe[0..target_exe.len])) {
            if (state.pid_count < max_pids) {
                state.pids[state.pid_count] = entry.th32ProcessID;
                state.pid_count += 1;
            }
        }
        if (Process32NextW(snap, &entry) == 0) break;
    }
}

fn isTargetPid(pid: DWORD) bool {
    for (state.pids[0..state.pid_count]) |p| if (p == pid) return true;
    return false;
}

fn enumTopCb(hwnd: HWND, _: LPARAM) callconv(.winapi) BOOL {
    var pid: DWORD = 0;
    _ = GetWindowThreadProcessId(hwnd, &pid);
    if (isTargetPid(pid)) {
        _ = InvalidateRect(hwnd, null, 0);
    }
    return 1;
}

pub export fn wWinMain(
    _: ?win.HINSTANCE,
    _: ?win.HINSTANCE,
    _: ?win.LPWSTR,
    _: c_int,
) callconv(.winapi) c_int {
    var ticks_since_refresh: u32 = 0;
    while (true) {
        if (ticks_since_refresh == 0) refreshTargetPids();
        ticks_since_refresh = (ticks_since_refresh + 1) % 10;

        if (state.pid_count > 0) {
            _ = EnumWindows(&enumTopCb, 0);
        }
        Sleep(interval_ms);
    }
}
