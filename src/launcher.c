#include <windows.h>

int main(void)
{
    HWND hwnd = GetConsoleWindow();
    if (hwnd) {
        LONG style = GetWindowLong(hwnd, GWL_STYLE);
        style &= ~(WS_CAPTION | WS_THICKFRAME | WS_SYSMENU
                 | WS_MINIMIZEBOX | WS_MAXIMIZEBOX);
        SetWindowLong(hwnd, GWL_STYLE, style);
        SetWindowPos(hwnd, HWND_TOPMOST, 0, 0,
            GetSystemMetrics(SM_CXSCREEN),
            GetSystemMetrics(SM_CYSCREEN),
            SWP_FRAMECHANGED | SWP_SHOWWINDOW);
    }

    STARTUPINFOA si = { sizeof(si) };
    PROCESS_INFORMATION pi;
    char cmd[] = "cmd.exe /k X:\\Windows\\System32\\isoCMD.cmd";
    CreateProcessA(NULL, cmd, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi);
    WaitForSingleObject(pi.hProcess, INFINITE);
    return 0;
}