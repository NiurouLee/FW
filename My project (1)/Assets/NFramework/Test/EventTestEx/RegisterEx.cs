using System.Reflection.Emit;
using NFramework.Event;
using UnityEngine;

namespace NFramework.Test.EventTestEx
{
    public class RegisterEx
    {
        public void TestRegister()
        {
            EventManager.D.Subscribe<NormalEvent>(this.OnNormalEvent);
        }

        private void OnNormalEvent(ref NormalEvent normalEvent)
        {
            UnityEngine.Debug.Log("OnNormalEvent");
        }

        public void TestUnRegister()
        {
            EventManager.D.UnSubscribe<NormalEvent>(this.OnNormalEvent);
        }

        public void TestRegister2()
        {
            var register = EventManager.D.Subscribe<NormalEvent>(this.OnNormalEvent);
        }

        public void TestRegisterChannel()
        {
            EventManager.D.Subscribe<ChannelEvent>(this.OnChannelEvent, "111");
        }

        private void OnChannelEvent(ref ChannelEvent initem)
        {
            UnityEngine.Debug.Log($"OnChannelEvent=>{initem.Channel}");
        }

        public void TestUnRegisterChannel()
        {
            EventManager.D.UnSubscribe<ChannelEvent>(this.OnChannelEvent, "111");
        }

        public void TestRegisterFilter()
        {
            EventManager.D.Subscribe<NormalEvent>(this.OnFilterEvent, this.Filter);
        }

        private void OnFilterEvent(ref NormalEvent initem)
        {
            UnityEngine.Debug.Log($"OnFilterEvent=>{initem.ID}");
        }

        public void TestUnRegisterFilter()
        {
            EventManager.D.UnSubscribe<NormalEvent>(this.OnFilterEvent, this.Filter);
        }

        private bool Filter(ref NormalEvent initem)
        {
            if (initem.ID == 1)
                return true;
            return false;
        }

        public void LogCount()
        {
            var normalCount = EventManager.D.GetCount<NormalEvent>();
            Debug.Log($"normalCount:{normalCount}");
            var channelCount = EventManager.D.GetCount<ChannelEvent>();
            Debug.Log($"channelCount:{channelCount}");
        }
    }
}