using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ClickBoard
{
    using System.Runtime.InteropServices;
    using HWND = IntPtr;

    /// <summary>Contains functionality to get all the open windows.</summary>
    public static class OpenWindowGetter
    {
        /// <summary>Returns a dictionary that contains the handle and title of all the open windows.</summary>
        /// <returns>A dictionary that contains the handle and title of all the open windows.</returns>
        public static IDictionary<uint, string> GetOpenWindows()
        {
            HWND shellWindow = GetShellWindow();
            Dictionary<uint, string> windows = new Dictionary<uint, string>();

            EnumWindows(delegate(HWND hWnd, int lParam)
            {
                if (hWnd == shellWindow) return true;
                if (!IsWindowVisible(hWnd)) return true;

                int length = GetWindowTextLength(hWnd);
                if (length == 0) return true;

                StringBuilder builder = new StringBuilder(length);
                GetWindowText(hWnd, builder, length + 1);
                uint processID;
                GetWindowThreadProcessId(hWnd, out processID);

                windows[processID] = builder.ToString();
                return true;

            }, 0);

            return windows;
        }

        delegate bool EnumWindowsProc(HWND hWnd, int lParam);

        [DllImport("USER32.DLL")]
        static extern bool EnumWindows(EnumWindowsProc enumFunc, int lParam);

        [DllImport("USER32.DLL")]
        static extern int GetWindowText(HWND hWnd, StringBuilder lpString, int nMaxCount);

        [DllImport("USER32.DLL")]
        static extern int GetWindowTextLength(HWND hWnd);

        [DllImport("USER32.DLL")]
        static extern bool IsWindowVisible(HWND hWnd);

        [DllImport("USER32.DLL")]
        static extern IntPtr GetShellWindow();

        [DllImport("user32.dll", SetLastError = true)]
        static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
    }

    public class Windows
    {
        public string type = "windows";
        public List<Window> windows = new List<Window>();

        public void AddWindow(Window window) {
            windows.Add(window);
        }
    }

    public class Window
    {
        public string type = "window";
        public uint pid;
        public string title;
    }
}
