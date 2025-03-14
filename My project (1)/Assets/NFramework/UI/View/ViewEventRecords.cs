using NFramework.Core;
using NFramework.Event;

namespace NFramework.UI
{
    public partial class View
    {
        private EventRecords m_viewEventRecords;

        private EventRecords ViewEventRecords
        {
            get
            {
                if (m_viewEventRecords == null)
                {
                    m_viewEventRecords = ObjectPool.Alloc<EventRecords>();
                }
                return m_viewEventRecords;
            }
        }
    }
}
