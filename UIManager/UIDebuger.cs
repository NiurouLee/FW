using UnityEngine;

namespace Ez.UI
{
    /// <summary>
    /// UI 管理器开发期间调试使用
    /// </summary>
    public sealed class UIDebuger
    {

#if UNITY_EDITOR
        public const string UI_TAG = "<color=orange>[UI]</color> [FRAME({0,4})] <color=lime>[{1}]</color> {2}";
#else
        public const string UI_TAG = "[UI] [FRAME:({0,4})] [{1}] {2}";
#endif

        [System.Diagnostics.Conditional("CLIENT_UIMANAGER_DEBUG")]
        public static void LogKey(string tag, string msg)
        {
            Debug.LogFormat(UI_TAG, Time.frameCount, tag, msg);
        }

        [System.Diagnostics.Conditional("CLIENT_UIMANAGER_DEBUG_DETAIL")]
        public static void LogDetail(string tag, string msg)
        {
            Debug.LogFormat(UI_TAG, Time.frameCount, tag, msg);
        }

        [System.Diagnostics.Conditional("CLIENT_UIMANAGER_DEBUG_DETAIL")]
        public static void UIWarning(string tag, string msg)
        {
            Debug.LogFormat(UI_TAG, Time.frameCount, tag, msg);
        }

        [System.Diagnostics.Conditional("CLIENT_UIMANAGER_DEBUG_PROFILER")]
        public static void BeginSample(string name)
        {
            Ez.Core.ProfilerUtil.BeginSample(name);
        }

        [System.Diagnostics.Conditional("CLIENT_UIMANAGER_DEBUG_PROFILER")]
        public static void EndSample()
        {
            Ez.Core.ProfilerUtil.EndSample();
        }
    }
}
