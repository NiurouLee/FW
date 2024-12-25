//using System.Text;

//namespace client
//{
//    public enum LogFlags : uint
//    {
//        None = 0,
//        Error = 1 << 0,
//        Warning = 1 << 1,
//        Log = 1 << 2,

//        All = 0xFFFFFFFF,
//    }

//    public static class Loger
//    {
//        private static LogFlags logFlags = LogFlags.All;
//        private static StringBuilder sb = new StringBuilder(1024);

//        static Loger()
//        {
//            logFlags = LogFlags.Log | LogFlags.Warning | LogFlags.Error;
//        }

//        public static void SetFilter(LogFlags flags)
//        {
//            logFlags = flags;
//        }

//        public static void Log(string message, params object[] args)
//        {
//            if ((logFlags & LogFlags.Log) == LogFlags.None)
//            {
//                return;
//            }

//            sb.Clear();
//            sb.Append(message);
//            if (args != null)
//            {
//                foreach (var item in args)
//                {
//                    sb.Append(item.ToString());
//                }
//            }
//            UnityEngine.Debug.Log(sb.ToString());
//        }

//        public static void LogWarning(string message, params object[] args)
//        {
//            if ((logFlags & LogFlags.Warning) == LogFlags.None)
//            {
//                return;
//            }

//            sb.Clear();
//            sb.Append(message);
//            if (args != null)
//            {
//                foreach (var item in args)
//                {
//                    sb.Append(item.ToString());
//                }
//            }

//            UnityEngine.Debug.LogWarning(sb.ToString());
//        }

//        public static void LogError(string message, params object[] args)
//        {
//            if ((logFlags & LogFlags.Error) == LogFlags.None)
//            {
//                return;
//            }

//            sb.Clear();
//            sb.Append(message);
//            if (args != null)
//            {
//                foreach (var item in args)
//                {
//                    sb.Append(item.ToString());
//                }
//            }
//            UnityEngine.Debug.LogError(sb.ToString());
//        }
//    }
//}