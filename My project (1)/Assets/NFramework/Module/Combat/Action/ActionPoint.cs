using System.Collections.Generic;
using NFramework.Module.EntityModule;
using System;

namespace NFramework.Module.Combat
{
    public class ActionPoint
    {
        private List<Action<Entity>> _listenerList = new List<Action<Entity>>();

        public void AddListener(Action<Entity> listener)
        {
            _listenerList.Add(listener);
        }

        public void RemoveListener(Action<Entity> listener)
        {
            _listenerList.Remove(listener);
        }
        public void TriggerActionPoint(Entity inActionExecution)
        {
            if (inActionExecution == null)
            {
                return;
            }
            if (_listenerList.Count == 0)
            {
                return;
            }

            for (int i = _listenerList.Count - 1; i >= 0; i--)
            {
                _listenerList[i](inActionExecution);
            }
        }

    }
}