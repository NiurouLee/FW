using System;
using NFramework.Core.Collections;
using Unity.VisualScripting.Antlr3.Runtime;

namespace NFramework.Module.LogModule
{
    public class LoggerM : IFrameWorkModule
    {

        public BitField16 LogLevel = new BitField16(0);

        public void ErrStack(string inMsg)
        {
            UnityEngine.Debug.LogError(Environment.StackTrace);
            Err(inMsg);
        }

        public void Log(string inMsg)
        {
            UnityEngine.Debug.Log(inMsg);
        }

        public void Warn(string inMsg)
        {
            UnityEngine.Debug.LogWarning(inMsg);
        }
        public void Err(string inMsg)
        {
            UnityEngine.Debug.LogError(inMsg);
        }


        public void Exception(System.Exception inMsg)
        {
            UnityEngine.Debug.LogError(Environment.StackTrace);
            throw inMsg;
        }
    }
}