using NFramework.Core.ObjectPool;
using NFramework.Module.Event;

namespace NFramework.Module.UI
{
    public partial class View
    {
        private EventRecords m_viewEventRecords;

        private EventRecords Event
        {
            get
            {
                if (m_viewEventRecords == null)
                {
                    m_viewEventRecords = ObjectPool.Alloc<EventRecords>();
                    m_viewEventRecords.Awake();
                    m_viewEventRecords.SetSchedule(Framework.Instance.GetModule<EventD>().D);
                }
                return m_viewEventRecords;
            }
        }

        private void DestroyEventRecords()
        {
            if (m_viewEventRecords != null)
            {
                m_viewEventRecords.Destroy();
                ObjectPool.Free(m_viewEventRecords);
                m_viewEventRecords = null;
            }
        }
    }
}
