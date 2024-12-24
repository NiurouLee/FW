using Ez.Core;
using System;
using UnityEngine;

namespace Ez.Lua
{
    public class LuaEventBridge : Singleton<LuaEventBridge>
    {
        private Action<string, UnityEngine.Object, object, object> onReceiveEventHandler = null;
        private Action<int, UnityEngine.Object, object, object> onReceiveEventIntHandler = null;
        private bool isInit = false;

        public override void Init()
        {
            isInit = true;
        }

        public override void Final()
        {
            isInit = false;
            onReceiveEventHandler = null;
            onReceiveEventIntHandler = null;
        }

        public void SendToLuaEvent(string eventId, UnityEngine.Object sender, object param, object tag = null)
        {
            try
            {
                if (onReceiveEventHandler != null)
                {
                    onReceiveEventHandler(eventId, sender, param, tag);
                }
                else
                {
                    if (isInit)
                    {
                        Debug.LogError("SendToLuaEvent handler is null");
                    }
                }
            }
            catch (System.Exception ex)
            {
                UnityEngine.Debug.LogException(ex);
            }
        }

        public void SendToLuaEvent(int eventId, UnityEngine.Object sender, object param, object tag = null)
        {
            try
            {
                if (onReceiveEventIntHandler != null)
                {
                    onReceiveEventIntHandler(eventId, sender, param, tag);
                }
                else
                {
                    Debug.LogError("SendToLuaEventInt Handler is null");
                }
            }
            catch (System.Exception ex)
            {
                UnityEngine.Debug.LogException(ex);
            }
        }

        public void SetStringEventHandler(Action<string, UnityEngine.Object, object, object> handler)
        {
            onReceiveEventHandler = handler;
        }

        public void SetIntEventHandler(Action<int, UnityEngine.Object, object, object> handler)
        {
            onReceiveEventIntHandler = handler;
        }
    }
}

