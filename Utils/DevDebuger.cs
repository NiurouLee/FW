using System;
using System.Diagnostics;
using System.Text;
using Ez.Core;
using Game.Sdk.Report;
using Google.Protobuf;
using UnityEngine;
using Debug = UnityEngine.Debug;

namespace Game
{
    public static class DevDebuger
    {
#if UNITY_EDITOR
        public const string MTAG = "<color=orange>[CLIENT]</color> [FRAME({0,4})] <color=lime>[{1}]</color> {2}";
#else
        public const string MTAG = "[CLIENT] [FRAME:({0,4})] [{1}] {2}";
#endif
        public const string MTAG_REPORT = "[CLIENT] [FRAME:({0,4})] [{1}] {2}";
        private static readonly LogReport logReport = LogReport.GetInstance();

        public static void LogStep(string tag, string msg)
        {
            // if(logReport.CheckDebug(LogType.Log))
            if (logReport.CD(UnityEngine.LogType.Log))
            {
                Debug.LogFormat(MTAG, Time.frameCount, tag, msg);
                logReport.Log(string.Format(MTAG_REPORT, Time.frameCount, tag, msg), "MSG");
            }
        }

        private static string LOG = "[CLIENT] [Frame: ";
        private static string NET = "[NET] [Frame: ";

        // static StringBuilder sb = StringBuilderPool.Acquire();
        static string Format(string type, int c, string tag, string msg, UnityEngine.LogType level = UnityEngine.LogType.Log)
        {
            StringBuilder sb = StringBuilderPool.Acquire();
            sb.Append(DateTime.Now.ToString("HH:mm:ss:fff"));
            sb.Append(" [");
            sb.Append(level.ToString());
            sb.Append("]: ");
            sb.Clear();
            sb.Append(type);
            sb.Append(c);
            sb.Append("] [");
            sb.Append(tag);
            sb.Append("] ");
            sb.Append(msg);
            return StringBuilderPool.GetStringAndRelease(sb);
        }


        [System.Diagnostics.Conditional("CLIENT_COMMON_DEBUG")]
        public static void Log(string tag, string msg)
        {
#if UNITY_EDITOR
            Debug.LogFormat(MTAG, Time.frameCount, tag, msg);
#endif
            // if(logReport.CheckDebug(LogType.Log))
            if (logReport.CD(UnityEngine.LogType.Log))
            {
                string s = Format(LOG, Time.frameCount, tag, msg, UnityEngine.LogType.Log);
#if !UNITY_EDITOR
                Debug.Log(s);
#endif
                logReport.Log(s, "MSG");
            }
        }

        [System.Diagnostics.Conditional("CLIENT_COMMON_DEBUG")]
        public static void LogWarning(string tag, string msg)
        {
#if UNITY_EDITOR
            Debug.LogWarningFormat(MTAG, Time.frameCount, tag, msg);
#endif
            // if(logReport.CheckDebug(LogType.Log))
            if (logReport.CD(UnityEngine.LogType.Warning))
            {
                string s = Format(LOG, Time.frameCount, tag, msg, UnityEngine.LogType.Warning);
#if !UNITY_EDITOR
                Debug.LogWarning(s);
#endif
                logReport.LogWarning(s, "MSG");
            }
        }

        public static void LogError(string tag, string msg, bool showstack = false)
        {
#if UNITY_EDITOR
            Debug.LogErrorFormat(MTAG, Time.frameCount, tag, msg);
#endif
            // if(logReport.CheckDebug(LogType.Log))
            if (logReport.CD(UnityEngine.LogType.Error))
            {
                string stackInfo = showstack ? GetStackInfo(new StackTrace(1, true)) : "";
                string s = Format(LOG, Time.frameCount, tag, msg, UnityEngine.LogType.Error);
                logReport.LogError(s, "MSG", stackInfo);
            }
        }

        [System.Diagnostics.Conditional("CLIENT_COMMON_DEBUG")]
        public static void Assert(bool condition, string message)
        {
            Debug.Assert(condition, string.Format(MTAG_REPORT, Time.frameCount, "assert", message));
        }

        /**************************************************************************************************************/
        const string NETTAG = "[NET] [FRAME:({0,4})] [{1}] {2}";

        /// <summary>
        /// 网络基础相关输出
        /// </summary>
        /// <param name="tag"></param>
        /// <param name="msg"></param>
        //[System.Diagnostics.Conditional("CLIENT_NETWORK_DEBUG")]
        public static void LogNet(string tag, string msg)
        {
#if UNITY_EDITOR
            Debug.LogFormat(NETTAG, Time.frameCount, tag, msg);
#endif
            // if(logReport.CheckDebug(LogType.Log))
            if (logReport.CD(UnityEngine.LogType.Log))
            {
                string s = Format(NET, Time.frameCount, tag, msg);
#if !UNITY_EDITOR
                Debug.Log(s);
#endif
                logReport.Log(s, "MSG");
            }
        }

#if UNITY_EDITOR
        const string SEND_PROTO = "[MSG][FRAME:({0,4})] <color=cyan>[{1}]\t{2}</color>";
        const string RECV_PROTO = "[MSG][FRAME:({0,4})] <color=yellow>[{1}]</color>\n{2}";
#else
            const string SEND_PROTO = "[MSG][FRAME:({0,4})] [{1}]\t{2}";
            const string RECV_PROTO = "[MSG][FRAME:({0,4})] [{1}]\n{2}";
#endif
        private static string NET_SEND = "[NET_SEND] [Frame: ";
        private static string NET_PROTO = "[NET_PROTO] [Frame: ";

        /// <summary>
        /// 网络消息相关输出
        /// </summary>
        /// <param name="uri"></param>
        /// <param name="msg"></param>
        /// <param name="isSend"></param>
        //[System.Diagnostics.Conditional("CLIENT_NETMSG_DEBUG")]
        public static void LogNetMsg(string uri, IMessage msg, bool isSend = false)
        {
            if (uri == "netutils.Ping" || uri == "netutils.PingAck")
            {
                return;
            }

            if (isSend)
            {
#if UNITY_EDITOR
                Debug.LogFormat(SEND_PROTO, Time.frameCount, uri, msg.ToString());
                if (logReport.CD(UnityEngine.LogType.Log))
                {
                    logReport.Log(string.Format(MTAG_REPORT, Time.frameCount, uri, msg.ToString()), "MSG");
                }
#else
                if (logReport.CD(UnityEngine.LogType.Log))
                {
                    string s = Format(NET_SEND, Time.frameCount, uri, msg.ToString());
#if !UNITY_EDITOR
                    Debug.Log(s);
#endif
                    logReport.Log(s, "MSG");
                }
#endif
            }
            else
            {
                if (s_MsgFormatter == null)
                {
                    JsonFormatter.Settings set = JsonFormatter.Settings.Default.WithFormatDefaultValues(true) //设置默认值是否显示
                        .WithIndentation("\t");
                    s_MsgFormatter = new JsonFormatter(set);
                }
#if UNITY_EDITOR
                Debug.LogFormat(RECV_PROTO, Time.frameCount, uri, s_MsgFormatter.Format(msg));
                if (logReport.CD(UnityEngine.LogType.Log))
                {
                    logReport.Log(string.Format(MTAG_REPORT, Time.frameCount, uri, s_MsgFormatter.Format(msg)), "MSG");
                }
#else
                if (logReport.CD(UnityEngine.LogType.Log))
                {
                    string s = Format(NET_PROTO, Time.frameCount, uri, s_MsgFormatter.Format(msg));
#if !UNITY_EDITOR
                    Debug.Log(s);
#endif
                    logReport.Log(s, "MSG");
                }
#endif
            }
        }

        private static JsonFormatter s_MsgFormatter;

        /**************************************************************************************************************/

        /// <summary>
        /// 事件系统相关输出
        /// </summary>
        /// <param name="tag"></param>
        /// <param name="msg"></param>
        [System.Diagnostics.Conditional("CLIENT_EVENT_DEBUG")]
        public static void LogEvent(string tag, string msg)
        {
#if UNITY_EDITOR
            const string BTAG = "<color=orange>[EVENT]</color> [FRAME({0,4})] <color=lime>[{1}]</color> {2}";
#else
            const string BTAG = "[EVENT] [FRAME:({0,4})] [{1}] {2}";
#endif
            Debug.LogFormat(BTAG, Time.frameCount, tag, msg);
        }

        /**************************************************************************************************************/
        public static string GetStackInfo(System.Diagnostics.StackTrace st)
        {
            int FilePathSubIndex = Application.dataPath.Length - "Assets".Length;

            var sb = Ez.Core.StringBuilderPool.Acquire();
            sb.AppendLine();

            var sarr = st.GetFrames();
            for (int i = 0; i < sarr.Length; i++)
            {
                var item = sarr[i];
                string fileName = item.GetFileName();
                if (string.IsNullOrEmpty(fileName))
                {
                    sb.AppendLine($"null - {i}");
                }
                else
                {
                    string assetPath = item.GetFileName().Substring(FilePathSubIndex).Replace('\\', '/');
                    sb.AppendLine($"<a href=\"{assetPath}\" line=\"{item.GetFileLineNumber()}\"> {assetPath}:{item.GetFileLineNumber()}</a>");
                }
            }

            return Ez.Core.StringBuilderPool.GetStringAndRelease(sb);
        }

        /// <summary>
        /// 仅编辑器下，输出已记录的堆栈信息
        /// </summary>
        /// <param name="tag"></param>
        /// <param name="st"></param>
        [System.Diagnostics.Conditional("UNITY_EDITOR")]
        public static void LogStackTrace(string tag, StackTrace st, LogType logType = LogType.Log)
        {
            int FilePathSubIndex = Application.dataPath.Length - "Assets".Length;

            var sb = Ez.Core.StringBuilderPool.Acquire();
            sb.AppendLine();

            var sarr = st.GetFrames();
            for (int i = 0; i < sarr.Length; i++)
            {
                var item = sarr[i];
                string fileName = item.GetFileName();
                if (string.IsNullOrEmpty(fileName))
                {
                    sb.AppendLine($"null - {i}");
                }
                else
                {
                    string assetPath = item.GetFileName().Substring(FilePathSubIndex).Replace('\\', '/');
                    sb.AppendLine($"<a href=\"{assetPath}\" line=\"{item.GetFileLineNumber()}\"> {assetPath}:{item.GetFileLineNumber()}</a>");
                }
            }

            const string STACK_TRACE = "<color=orange>[STACK]</color> [FRAME({0,4})] [{1}] {2}";

            switch (logType)
            {
                case LogType.Log:
                    Debug.LogFormat(STACK_TRACE, Time.frameCount, tag, Ez.Core.StringBuilderPool.GetStringAndRelease(sb));
                    break;
                case LogType.Warning:
                    Debug.LogWarningFormat(STACK_TRACE, Time.frameCount, tag, Ez.Core.StringBuilderPool.GetStringAndRelease(sb));
                    break;
                case LogType.Error:
                    Debug.LogErrorFormat(STACK_TRACE, Time.frameCount, tag, Ez.Core.StringBuilderPool.GetStringAndRelease(sb));
                    break;
                default:
                    Debug.LogWarningFormat(STACK_TRACE, Time.frameCount, tag, Ez.Core.StringBuilderPool.GetStringAndRelease(sb));
                    break;
            }
        }
    }
}