using Ez.Assets;
using Ez.Core;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

namespace Ez.UI
{
    public class UIEventManager : Singleton<UIEventManager>
    {
        private EventProcessor _eventProcessor;

        public UIEventManager()
        {
            _eventProcessor = new EventProcessor(nameof(UIEventManager));
        }

        public override void Final()
        {
            _eventProcessor.Clear();
            _eventProcessor = null;
        }

        public override void Init()
        {

        }

        public void Fire(string evtName, object param = null)
        {
            _eventProcessor.Fire(evtName, param);
        }

        public void Listen(string evtName, EventHandler callback)
        {
            _eventProcessor.Add(evtName, callback);
        }

        public void UnListen(string evtName, EventHandler callback)
        {
            _eventProcessor.Remove(evtName, callback);
        }

        public void Check()
        {
            //TODO@bao 23/11/29
        }
    }
}