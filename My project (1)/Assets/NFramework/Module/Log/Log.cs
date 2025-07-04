using System;
using System.Diagnostics;

namespace NFramework.Module.Log
{
    public class LoggerModule : IFrameWorkModule
    {
        public void ErrStack(string inMsg)
        {
            UnityEngine.Debug.LogError(Environment.StackTrace);
            Err(inMsg);
        }

        public void Debug(string inMsg)
        {
            UnityEngine.Debug.Log(inMsg);
        }

        public void Err(string inMsg)
        {
            UnityEngine.Debug.LogError(inMsg);
        }

        public void Warn(string inMsg)
        {
            UnityEngine.Debug.LogWarning(inMsg);
        }

        public void Exception(System.Exception inMsg)
        {
            UnityEngine.Debug.LogError(Environment.StackTrace);
            throw inMsg;
        }
    }
}