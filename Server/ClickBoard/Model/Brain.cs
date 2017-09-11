using Shell32;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;
using WindowsInput;
using iTunesLib;
using System.Threading;
using System.Web.Script.Serialization;
using System.Net.Sockets;
using ClickBoard.Properties;

namespace ClickBoard
{
    class Brain
    {
        [DllImport("USER32.DLL", CharSet = CharSet.Unicode)]
        public static extern IntPtr FindWindow(String lpClassName, String lpWindowName);

        [DllImport("User32.Dll", EntryPoint = "LockWorkStation"), Description("Locks the workstation's display. Locking a workstation protects it from unauthorized use.")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool LockWorkStation();
        
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        private static extern int GetWindowTextLength(IntPtr hWnd);

        [DllImport("USER32.DLL")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);

        [DllImport("user32.dll", SetLastError = true)]
        static extern IntPtr GetWindow(IntPtr hWnd, uint uCmd);

        [DllImport("user32.dll")]
        static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll")]
        static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
        private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

        [DllImport("user32.dll")]
        private static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);

        [DllImport("user32.dll", SetLastError = true)]
        static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);

        [DllImport("user32.dll")]
        static extern bool DestroyWindow(IntPtr hWnd);

        [DllImport("User32.dll")]
        public static extern long SetCursorPos(int x, int y);

        [DllImport("User32.dll")]
        public static extern bool ClientToScreen(IntPtr hWnd, ref POINT point);

        [StructLayout(LayoutKind.Sequential)]
        public struct POINT
        {
            public int x;
            public int y;
        }

        static Random rnd = new Random();

        InputSimulator inputSimulator = new InputSimulator();

        double xBaseMultiplier = 1.8;
        double yBaseMultiplier = 2.7;

        double xMultiplier = 1.8;
        double yMultiplier = 2.7;

        public Socket connectedSocket;
        
        public void ProcessData(string received)
        {
            try
            {

                string[] receivedArray = received.Split(new[] { ":" }, StringSplitOptions.RemoveEmptyEntries);
                if (receivedArray.Length >= 1)
                {
                    string command = receivedArray[0];
                    string content = "";
                    if (receivedArray.Length > 1)
                    {
                        content = receivedArray[1];
                    }

                    if (String.Equals(command, "a"))
                    {
                        LeftClick(content);
                    }
                    else if (String.Equals(command, "b"))
                    {
                        RightClick(content);
                    }
                    else if (String.Equals(command, "c"))
                    {
                        Scroll(content);
                    }
                    else if (String.Equals(command, "d"))
                    {
                        LaunchApp(content);
                    }
                    else if (String.Equals(command, "e"))
                    {
                        Keyboard(content);
                    }
                    else if (String.Equals(command, "f"))
                    {
                        ControlComputer(content);
                    }
                    else if (String.Equals(command, "g"))
                    {
                        MediaController(content);
                    }
                    else if (String.Equals(command, "h"))
                    {
                        Volume(content);
                    }
                    else if (String.Equals(command, "i"))
                    {
                        GetItunesInfo(content);
                    }
                    else if (String.Equals(command, "v"))
                    {
                        ApplicationController(content);
                    }
                    else if (String.Equals(command, "w"))
                    {
                        OpenProcess(content);
                    }
                    else if (String.Equals(command, "x"))
                    {
                        CloseProcess(content);
                    }
                    else if (String.Equals(command, "y"))
                    {
                        Trackpad(content);
                    }
                    else if (String.Equals(command, "z"))
                    {
                        Movement(content);
                    }
                }
            }
            catch { }
        }

        public static string ReplaceContent(string content)
        {
            content = content.Replace("a", "");
            content = content.Replace("b", "");
            content = content.Replace("c", "");
            content = content.Replace("c", "");
            content = content.Replace("e", "");
            content = content.Replace("f", "");
            content = content.Replace("g", "");
            content = content.Replace("h", "");
            content = content.Replace("i", "");
            content = content.Replace("j", "");
            content = content.Replace("y", "");
            content = content.Replace("z", "");
            return content;
        }

        public void LeftClick(string content)
        {
            content = ReplaceContent(content);
            if(String.Equals(content, "1")) {
                inputSimulator.Mouse.LeftButtonDown();
            }
            else if(String.Equals(content, "2")) {
                
                inputSimulator.Mouse.LeftButtonUp();
            }
            else {
                inputSimulator.Mouse.LeftButtonClick();
            }
        }

        public void RightClick(string content)
        {
            content = ReplaceContent(content);
            inputSimulator.Mouse.RightButtonClick();
        }

        public void Scroll(string content)
        {
            if(String.Equals(content, "1")) {
                //Scroll Down
                inputSimulator.Mouse.VerticalScroll(6);
            }
            else if(String.Equals(content, "2")) {
                //Scroll Up
                inputSimulator.Mouse.VerticalScroll(-6);
            }
            else if(String.Equals(content, "3")) {
                //Scroll Right
                inputSimulator.Mouse.HorizontalScroll(6);
            }
            else if(String.Equals(content, "4")) {
                //Scroll Left
                inputSimulator.Mouse.HorizontalScroll(-6);
            }
        }

        public void LaunchApp(string content)
        {
            content = content.Replace("z", "");
            if (String.Equals(content, "desktop"))
            {
                inputSimulator.Keyboard.ModifiedKeyStroke(WindowsInput.Native.VirtualKeyCode.LWIN, WindowsInput.Native.VirtualKeyCode.VK_D);
            }
            else if (String.Equals(content, "start"))
            {
                inputSimulator.Keyboard.KeyPress(WindowsInput.Native.VirtualKeyCode.LWIN);
            }
            else
            {
                ProcessStartInfo start = new ProcessStartInfo();
                start.FileName = content;
                try
                {
                    Process.Start(start);
                }
                catch { }
            }
        }

        public void Keyboard(string content)
        {
            List<WindowsInput.Native.VirtualKeyCode> modifiers = new List<WindowsInput.Native.VirtualKeyCode>();
            List<WindowsInput.Native.VirtualKeyCode> keys = new List<WindowsInput.Native.VirtualKeyCode>();

            if (String.Equals(content, "ctatdl"))
            {
                LaunchApp("taskmgr.exe");
                return;
            }
            else if (String.Equals(content, "fat4"))
            {
                SendKeys.SendWait("%{F4}");
                return;
            }
            else if (String.Equals(content, "attb"))
            {
                FindWindows();
                return;
            }
            if (content.Contains("ct"))
            {
                content = content.Replace("ct", "");
                modifiers.Add(WindowsInput.Native.VirtualKeyCode.CONTROL);
            }
            if (content.Contains("at")) 
            {
                content = content.Replace("at", "");
                modifiers.Add(WindowsInput.Native.VirtualKeyCode.MENU);
            }

            if (modifiers.Count == 0 && content.Length == 1)
            {
                inputSimulator.Keyboard.TextEntry(content);
            }
            else
            {
                keys = KeyboardHelper.VirtualKeyCodesFromString(content, inputSimulator);
                if (KeyboardHelper.UpperCase(content))
                {
                    modifiers.Add(WindowsInput.Native.VirtualKeyCode.SHIFT);
                }

                inputSimulator.Keyboard.ModifiedKeyStroke(modifiers, keys);
            }
        }

        public static string GetWindowText(IntPtr hWnd)
        {
            int size = GetWindowTextLength(hWnd);
            if (size++ > 0)
            {
                var builder = new StringBuilder(size);
                GetWindowText(hWnd, builder, builder.Capacity);
                return builder.ToString();
            }

            return String.Empty;
        }

        public static void FindWindows()
        {
            IntPtr found = IntPtr.Zero;
            HashSet<int> windows = new HashSet<int>();

            EnumWindows(delegate(IntPtr wnd, IntPtr param)
            {
                uint processID;
                GetWindowThreadProcessId(wnd, out processID);
                Process process = Process.GetProcessById((int)processID);
                if (process.MainWindowTitle != null && process.MainWindowTitle.Length > 0 && !process.MainWindowTitle.Equals(" "))
                {
                    windows.Add((int)processID);
                }
                return true;
            },
                        IntPtr.Zero);

            List<Process> processes = new List<Process>();
            foreach (int processID in windows) {
                Process process = Process.GetProcessById(processID);
                processes.Add(process);
            }

            if (processes.Count > 1)
            {
                IntPtr currentHandle = GetForegroundWindow();
                if(currentHandle != IntPtr.Zero) 
                {
                    uint currentProcessID;
                    GetWindowThreadProcessId(currentHandle, out currentProcessID);
                    Process currentProcess = Process.GetProcessById((int)currentProcessID);

                    Process randomProcess = null;
                    while(randomProcess == null) {
                        int randomIndex = rnd.Next(processes.Count);
                        Process aProcess = processes[randomIndex];
                        if (!String.Equals(aProcess.MainWindowTitle, currentProcess.MainWindowTitle))
                        {
                            randomProcess = aProcess;
                        }
                    }

                    IntPtr mainHandle = randomProcess.MainWindowHandle;
                    if(mainHandle != IntPtr.Zero) 
                    {
                        SetForegroundWindow(mainHandle);
                    }
                }
            }
        }

        public void ControlComputer(string content)
        {
            if(String.Equals(content, "0")) {
                LockWorkStation();
            }
            else if(String.Equals(content, "1")) {
                var psi = new ProcessStartInfo("shutdown","/s /t 0");
                psi.CreateNoWindow = true;
                psi.UseShellExecute = false;
                Process.Start(psi);
            }
            else if(String.Equals(content, "2")) {
                var psi = new ProcessStartInfo("shutdown","/r");
                psi.CreateNoWindow = true;
                psi.UseShellExecute = false;
                Process.Start(psi);
            }
            else if(String.Equals(content, "3")) {
                Application.SetSuspendState(PowerState.Suspend, true, true);
            }
            else if(String.Equals(content, "4")) {
                Application.SetSuspendState(PowerState.Hibernate, true, true);
            }
        }

        public void ApplicationController(string content)
        {
            try
            {
                Windows windows = new Windows();

                foreach (KeyValuePair<uint, string> window in OpenWindowGetter.GetOpenWindows())
                {
                    Window aWindow = new Window
                    {
                        pid = window.Key,
                        title = window.Value
                    };
                    windows.AddWindow(aWindow);
                }

                string json = new JavaScriptSerializer().Serialize(windows);
                SendString(json);
            }
            catch { }
        }

        public void OpenProcess(string content)
        {
            try
            {
                Process process = Process.GetProcessById(Convert.ToInt32(content));
                IntPtr windowHandle = process.MainWindowHandle;
                if(windowHandle != IntPtr.Zero) 
                {
                    SetForegroundWindow(windowHandle);
                }
                ApplicationController(content);
            }
            catch { }
        }

        public void CloseProcess(string content)
        {
            try
            {
                Process process = Process.GetProcessById(Convert.ToInt32(content));
                if (process != null)
                {
                    process.Kill();
                    ApplicationController(content);
                }
            }
            catch { }
        }

        public void MediaController(string content)
        {
            try
            {
                iTunesAppClass iTunes = new iTunesAppClass();
                if (String.Equals(content, "pl"))
                {
                    iTunes.Play();
                    Thread.Sleep(500);
                    LoadMedia(1);
                }
                else if (String.Equals(content, "pa"))
                {
                    iTunes.Pause();
                }
                else if (String.Equals(content, "pt"))
                {
                    iTunes.PreviousTrack();
                    Thread.Sleep(500);
                    LoadMedia(0);
                }
                else if (String.Equals(content, "nt"))
                {
                    iTunes.NextTrack();
                    Thread.Sleep(500);
                    LoadMedia(0);
                }
                else if (String.Equals(content, "sh"))
                {
                    iTunes.Play();
                    iTunes.CurrentPlaylist.Shuffle = !iTunes.CurrentPlaylist.Shuffle;
                    iTunes.NextTrack();
                    Thread.Sleep(500);
                    LoadMedia(0);
                }
            }
            catch { }
        }

        public void Volume(string content)
        {
            try
            {
                content = ReplaceContent(content).Replace("z", "").Replace("h", "");

                int audioVolume = 100;
                audioVolume = Convert.ToInt32(Convert.ToDouble(content));
                AudioHelper.SetVolume(audioVolume);
            }
            catch { }
        }

        public void GetItunesInfo(string content)
        {
            LoadMedia(0);
        }

        public void LoadMedia(int newPlayState)
        {
            try
            {
                bool iTunesOpen = Process.GetProcessesByName("iTunes").Any();
                if (!iTunesOpen)
                {
                    return;
                }
                iTunesAppClass iTunes = new iTunesAppClass();

                ITPlayerState playerState = iTunes.PlayerState;
                int playState = 0;
                if (newPlayState == 1)
                {
                    playState = 0;
                }
                else if (playerState == ITPlayerState.ITPlayerStatePlaying)
                {
                    playState = 0;
                }
                else if (playerState == ITPlayerState.ITPlayerStateStopped)
                {
                    playState = 1;
                }
                int volume = AudioHelper.GetVolume();

                string name = "";
                string artist = "";
                string album = "";
                if(iTunes.CurrentTrack != null) {
                    name = iTunes.CurrentTrack.Name;
                    artist = iTunes.CurrentTrack.Artist;
                    album = iTunes.CurrentTrack.Album;
                }

                iTunesSong song = new iTunesSong
                {
                    playState = playState,
                    volume = volume,
                    name = name,
                    artist = artist,
                    album = album
                };

                string json = new JavaScriptSerializer().Serialize(song);
                SendString(json);
            }
            catch { }
        }

        public void SendString(string data)
        {
            if (connectedSocket != null && connectedSocket.Connected && data != null)
            {
                byte[] messageData = Encoding.ASCII.GetBytes(data);
                connectedSocket.Send(messageData);
            }
        }

        public void Trackpad(string content)
        {
            content = ReplaceContent(content).Replace("g", "").Replace(":", "").Replace("y", "");

            string[] movements = content.Split(new[] {"a"}, StringSplitOptions.RemoveEmptyEntries);
            foreach (string movementString in movements) {
                string[] movement = movementString.Split(new[] {","}, StringSplitOptions.RemoveEmptyEntries);
                if (movement.Length >= 2)
                {
                    int screenWidth = SystemInformation.VirtualScreen.Width;
                    int screenHeight = SystemInformation.VirtualScreen.Height;
                    try {
                        double xCurrent = Cursor.Position.X;
                        double yCurrent = Cursor.Position.Y;

                        int xPosition = Convert.ToInt32(Convert.ToDouble(screenWidth) * Convert.ToDouble(movement[0]));
                        int yPosition = Convert.ToInt32(Convert.ToDouble(screenHeight) * Convert.ToDouble(movement[1]));

                        POINT p = new POINT();
                        p.x = xPosition;
                        p.y = yPosition;

                        SetCursorPos(p.x, p.y);
                    }
                    catch {}
                }
            }
        }

        public void Movement(string content)
        {
            content = content.Replace("g", "").Replace(":", "").Replace("z", "");
            string[] movements = content.Split(new[] {"a"}, StringSplitOptions.RemoveEmptyEntries);
            foreach (string movementString in movements) {
                string[] movement = movementString.Split(new[] {","}, StringSplitOptions.RemoveEmptyEntries);


                if(movementString.Length >= 2) {
                    int screenWidth = SystemInformation.VirtualScreen.Width;
                    int screenHeight = SystemInformation.VirtualScreen.Height;

                    try {
                         int xDelta = Convert.ToInt32(movement[0]);
                         double xSpeed = Convert.ToDouble(movement[1]);

                         int yDelta = Convert.ToInt32(movement[2]);
                         double ySpeed = Convert.ToDouble(movement[3]);


                         xMultiplier = xBaseMultiplier * Settings.Default.xMultiplier;
                         yMultiplier = yBaseMultiplier * Settings.Default.yMultipler;

                        double xDeltaAbs = xSpeed * xMultiplier + 2;
                        double yDeltaAbs = ySpeed * yMultiplier + 2;

                        if(xDelta == 1) {
                            //Moving Right
                            //xPosition += xDeltaAbs;                            
                        }
                        else if(xDelta == 2) {
                            //Moving Left
                            xDeltaAbs = -xDeltaAbs;
                            //xPosition -= xDeltaAbs;
                        }
                        
                        if(yDelta == 1) {
                            //Moving Up
                            yDeltaAbs = -yDeltaAbs;
                            //yPosition -= yDeltaAbs;
                        }
                        else if(yDelta == 2) {
                            //Moving Down
                            //yPosition += yDeltaAbs;
                        }
                        inputSimulator.Mouse.MoveMouseBy(Convert.ToInt32(xDeltaAbs), Convert.ToInt32(yDeltaAbs));
                         //inputSimulator.Mouse.MoveMouseTo(xPosition, yPosition);
                    }
                    catch { }
                }
            }
        }
    }

    static class Extensions
    {
        public static bool IsUpper(this string value)
        {
            // Consider string to be uppercase if it has no lowercase letters.
            for (int i = 0; i < value.Length; i++)
            {
                if (char.IsLower(value[i]))
                {
                    return false;
                }
            }
            return true;
        }

        public static bool IsLower(this string value)
        {
            // Consider string to be lowercase if it has no uppercase letters.
            for (int i = 0; i < value.Length; i++)
            {
                if (char.IsUpper(value[i]))
                {
                    return false;
                }
            }
            return true;
        }

        public static byte[] GetBytes(string str)
        {
            byte[] bytes = new byte[str.Length * sizeof(char)];
            System.Buffer.BlockCopy(str.ToCharArray(), 0, bytes, 0, bytes.Length);
            return bytes;
        }

        public static string GetString(byte[] bytes)
        {
            char[] chars = new char[bytes.Length / sizeof(char)];
            System.Buffer.BlockCopy(bytes, 0, chars, 0, bytes.Length);
            return new string(chars);
        }
    }
}
