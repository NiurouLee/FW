using Ez.Core;
using System.Collections.Generic;

namespace Ez.UI
{
    public abstract class UIStatusListener : IEventHandler
    {
        private HashSet<string> m_Set;
        private bool m_Disposed;

        public UIStatusListener()
        {
            ResMonitorUtil.Add("UIStatusListener", this);
            m_Disposed = false;
            m_Set = new HashSet<string>();
        }

        public abstract void Init();

        public abstract void Final();

        public abstract void OnHandleNotify(string evtName, object obj);


        protected bool Add(string eventKey)
        {
            if (string.IsNullOrEmpty(eventKey))
                return false;

            if (m_Disposed)
            {
                return false;
            }

            if (!m_Set.Contains(eventKey))
            {
                m_Set.Add(eventKey);
                UIEventManager.GetInstance().Listen(eventKey, OnHandleNotify);
                return true;
            }
            else
            {
                return false;
            }
        }

        protected bool Remove(string eventKey)
        {
            if (m_Disposed)
            {
                return false;
            }

            if (string.IsNullOrEmpty(eventKey) || m_Set == null)
            {
                return false;
            }

            if (m_Set.Contains(eventKey))
            {
                UIEventManager.GetInstance().UnListen(eventKey, OnHandleNotify);
                m_Set.Remove(eventKey);
                return true;
            }
            else
            {
                return false;
            }
        }

        public void Release()
        {
            m_Disposed = true;
            ResMonitorUtil.Remove("UIStatusListener", this);

            if (m_Set == null || m_Set.Count == 0)
            {
                return;
            }

            foreach (string eventKey in m_Set)
            {
                UIEventManager.GetInstance().UnListen(eventKey, OnHandleNotify);
            }
            m_Set.Clear();
            m_Set = null;
        }
    }
}
