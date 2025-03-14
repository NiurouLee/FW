using NFramework.Core;
using NFramework.Event;

namespace NFramework.UI
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
                    m_viewEventRecords.SetSchedule(EventManager.D);
                }
                return m_viewEventRecords;
            }
        }

        private void DestroyEventRecords()
        {
            if (m_viewEventRecords != null)
            {
                m_viewEventRecords.Destroy();
            }
        }
    }
}
