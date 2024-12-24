using System;
using System.Collections.Generic;

namespace Game
{
    public class StringSplitUtil
    {
        public static bool SplitList(string str, string ch, out string[] strs)
        {
            strs = null;
            if (string.IsNullOrEmpty(str) || string.IsNullOrEmpty(ch))
            {
                return false;
            }

            strs = str.Split(ch, StringSplitOptions.RemoveEmptyEntries);

            return true;
        }
        public static bool Split(string str, string ch, out string id, out string value)
        {
            id = null;
            value = null;
            if (string.IsNullOrEmpty(str) || string.IsNullOrEmpty(ch))
            {
                return false;
            }

            int index = str.IndexOf(ch);

            if (index == -1)
            {
                return false;
            }

            id = str.Substring(0, index);
            value = str.Substring(index + ch.Length);

            return true;
        }
    }
}