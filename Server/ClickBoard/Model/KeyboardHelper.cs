using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WindowsInput.Native;

namespace ClickBoard
{
    class KeyboardHelper
    {
        public static List<VirtualKeyCode> VirtualKeyCodesFromString(string keyString, WindowsInput.InputSimulator inputSimulator)
        {
            List<VirtualKeyCode> keys = new List<VirtualKeyCode>();
            if (keyString.Length == 2)
            {
                if (String.Equals(keyString, "kr"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.RIGHT);
                }
                else if (String.Equals(keyString, "kl"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.LEFT);
                }
                else if (String.Equals(keyString, "ku"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.UP);
                }
                else if (String.Equals(keyString, "kd"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.DOWN);
                }
                else if (String.Equals(keyString, "wn"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.LWIN);
                }
                else if (String.Equals(keyString, "bs"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.BACK);
                }
                else if (String.Equals(keyString, "dl"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.DELETE);
                }
                else if (String.Equals(keyString, "ec"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.ESCAPE);
                }
                else if (String.Equals(keyString, "rt"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.RETURN);
                }
                else if (String.Equals(keyString, "tb"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.TAB);
                }
                if (String.Equals(keyString, "f1"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.F1);
                }
                else if (String.Equals(keyString, "f2"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.F2);
                }
                else if (String.Equals(keyString, "f3"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.F3);
                }
                else if (String.Equals(keyString, "f4"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.F4);
                }
                else if (String.Equals(keyString, "f5"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.F5);
                }
                else if (String.Equals(keyString, "f6"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.F6);
                }
                else if (String.Equals(keyString, "f7"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.F7);
                }
                else if (String.Equals(keyString, "f8"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.F8);
                }
                else if (String.Equals(keyString, "f9"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.F9);
                }
                else if (String.Equals(keyString, "f10"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.F10);
                }
                else if (String.Equals(keyString, "f11"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.F11);
                }
                else if (String.Equals(keyString, "f12"))
                {
                    keys.Add(WindowsInput.Native.VirtualKeyCode.F12);
                }
            }

            else if (keyString.Length == 1)
            {
                keys.Add(VirtualKeycodeFromString(keyString, inputSimulator));
            }
            return keys;
        }

        public static VirtualKeyCode VirtualKeycodeFromString(string keyString, WindowsInput.InputSimulator inputSimulator)
        {
            VirtualKeyCode keyCode = VirtualKeyCode.NONAME;
            keyString = keyString.ToLower();

            if (String.Equals(keyString, "a"))
            {
                keyCode = VirtualKeyCode.VK_A;
            }
            else if (String.Equals(keyString, "b"))
            {
                keyCode = VirtualKeyCode.VK_B;
            }
            else if (String.Equals(keyString, "c"))
            {
                keyCode = VirtualKeyCode.VK_C;
            }
            else if (String.Equals(keyString, "d"))
            {
                keyCode = VirtualKeyCode.VK_D;
            }
            else if (String.Equals(keyString, "e"))
            {
                keyCode = VirtualKeyCode.VK_E;
            }
            else if (String.Equals(keyString, "f"))
            {
                keyCode = VirtualKeyCode.VK_F;
            }
            else if (String.Equals(keyString, "g"))
            {
                keyCode = VirtualKeyCode.VK_G;
            }
            else if (String.Equals(keyString, "h"))
            {
                keyCode = VirtualKeyCode.VK_H;
            }
            else if (String.Equals(keyString, "i"))
            {
                keyCode = VirtualKeyCode.VK_I;
            }
            else if (String.Equals(keyString, "j"))
            {
                keyCode = VirtualKeyCode.VK_J;
            }
            else if (String.Equals(keyString, "k"))
            {
                keyCode = VirtualKeyCode.VK_K;
            }
            else if (String.Equals(keyString, "l"))
            {
                keyCode = VirtualKeyCode.VK_L;
            }
            else if (String.Equals(keyString, "m"))
            {
                keyCode = VirtualKeyCode.VK_M;
            }
            else if (String.Equals(keyString, "n"))
            {
                keyCode = VirtualKeyCode.VK_N;
            }
            else if (String.Equals(keyString, "o"))
            {
                keyCode = VirtualKeyCode.VK_O;
            }
            else if (String.Equals(keyString, "p"))
            {
                keyCode = VirtualKeyCode.VK_P;
            }
            else if (String.Equals(keyString, "q"))
            {
                keyCode = VirtualKeyCode.VK_Q;
            }
            else if (String.Equals(keyString, "r"))
            {
                keyCode = VirtualKeyCode.VK_R;
            }
            else if (String.Equals(keyString, "s"))
            {
                keyCode = VirtualKeyCode.VK_S;
            }
            else if (String.Equals(keyString, "t"))
            {
                keyCode = VirtualKeyCode.VK_T;
            }
            else if (String.Equals(keyString, "u"))
            {
                keyCode = VirtualKeyCode.VK_U;
            }
            else if (String.Equals(keyString, "v"))
            {
                keyCode = VirtualKeyCode.VK_U;
            }
            else if (String.Equals(keyString, "v"))
            {
                keyCode = VirtualKeyCode.VK_V;
            }
            else if (String.Equals(keyString, "w"))
            {
                keyCode = VirtualKeyCode.VK_W;
            }
            else if (String.Equals(keyString, "x"))
            {
                keyCode = VirtualKeyCode.VK_X;
            }
            else if (String.Equals(keyString, "y"))
            {
                keyCode = VirtualKeyCode.VK_Y;
            }
            else if (String.Equals(keyString, "z"))
            {
                keyCode = VirtualKeyCode.VK_Z;
            }
            else if (String.Equals(keyString, "0") || String.Equals(keyString, ")"))
            {
                keyCode = VirtualKeyCode.VK_0;
            }
            else if (String.Equals(keyString, "1") || String.Equals(keyString, "!"))
            {
                keyCode = VirtualKeyCode.VK_1;
            }
            else if (String.Equals(keyString, "2") || String.Equals(keyString, '"'))
            {
                keyCode = VirtualKeyCode.VK_2;
            }
            else if (String.Equals(keyString, "3") || String.Equals(keyString, "£"))
            {
                keyCode = VirtualKeyCode.VK_3;
            }
            else if (String.Equals(keyString, "4") || String.Equals(keyString, "$"))
            {
                keyCode = VirtualKeyCode.VK_4;
            }
            else if (String.Equals(keyString, "5") || String.Equals(keyString, "%"))
            {
                keyCode = VirtualKeyCode.VK_5;
            }
            else if (String.Equals(keyString, "6") || String.Equals(keyString, "^"))
            {
                keyCode = VirtualKeyCode.VK_6;
            }
            else if (String.Equals(keyString, "7") || String.Equals(keyString, "&"))
            {
                keyCode = VirtualKeyCode.VK_7;
            }
            else if (String.Equals(keyString, "8") || String.Equals(keyString, "*"))
            {
                keyCode = VirtualKeyCode.VK_8;
            }
            else if (String.Equals(keyString, "9") || String.Equals(keyString, "("))
            {
                keyCode = VirtualKeyCode.VK_9;
            }
            else if (String.Equals(keyString, "-"))
            {
                keyCode = VirtualKeyCode.OEM_MINUS;
            }
            else if (String.Equals(keyString, "/") || String.Equals(keyString, "?"))
            {
                keyCode = VirtualKeyCode.OEM_2;
            }
            else if (String.Equals(keyString, ";") || String.Equals(keyString, ":"))
            {
                keyCode = VirtualKeyCode.OEM_1;
            }
            else if (String.Equals(keyString, "'") || String.Equals(keyString, "@"))
            {
                keyCode = VirtualKeyCode.OEM_7;
            }
            else if (String.Equals(keyString, "."))
            {
                keyCode = VirtualKeyCode.OEM_PERIOD;
            }
            else if (String.Equals(keyString, ","))
            {
                keyCode = VirtualKeyCode.OEM_COMMA;
            }
            else if (String.Equals(keyString, "[") || String.Equals(keyString, "{"))
            {
                keyCode = VirtualKeyCode.OEM_4;
            }
            else if (String.Equals(keyString, "]") || String.Equals(keyString, "}"))
            {
                keyCode = VirtualKeyCode.OEM_6;
            }
            else if (String.Equals(keyString, "~"))
            {
                keyCode = VirtualKeyCode.OEM_3;
            }
            else if (String.Equals(keyString, "\\") || String.Equals(keyString, "|"))
            {
                keyCode = VirtualKeyCode.OEM_5;
            }

            return keyCode;
        }

        public static bool UpperCase(string keyString)
        {
            if (keyString.IsUpper())
            {
                return true;
            }

            if (String.Equals(keyString, "|") || String.Equals(keyString, "}") || String.Equals(keyString, "{") || String.Equals(keyString, "@") || String.Equals(keyString, "?") || String.Equals(keyString, ":") || String.Equals(keyString, ")") || String.Equals(keyString, "!") || String.Equals(keyString, '"')  || String.Equals(keyString, "£")  || String.Equals(keyString, "$") || String.Equals(keyString, "%") || String.Equals(keyString, "^") || String.Equals(keyString, "&") || String.Equals(keyString, "*") || String.Equals(keyString, "("))
            {
                return true;
            }
            return false;
        }
    }
}
