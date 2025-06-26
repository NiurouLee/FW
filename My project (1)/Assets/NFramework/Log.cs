using System;
using System.Diagnostics;
using Unity.VisualScripting;
using UnityEditor.PackageManager;

namespace NFramework
{


    public static class Log
    {
        [Conditional("UNITY_EDITOR")]
        public static void ErrStack(string inMsg)
        {
            UnityEngine.Debug.LogError(Environment.StackTrace);
            Err(inMsg);
        }

        public static void Err(string inMsg)
        {
            UnityEngine.Debug.LogError(inMsg);
        }

        public static void Exception(System.Exception inMsg)
        {
            UnityEngine.Debug.LogError(Environment.StackTrace);
            throw inMsg;
        }
    }
}