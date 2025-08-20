using NFramework.Module.EventModule;
using NFramework.Module.ObjectPoolModule;

namespace NFramework.Module.UIModule
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
                    m_viewEventRecords = GetFrameworkModule<ObjectPoolM>().Alloc<EventRecords>();
                    m_viewEventRecords.Awake();
                    m_viewEventRecords.SetSchedule(Framework.Instance.GetModule<EventM>().D);
                }
                return m_viewEventRecords;
            }
        }

        private void DestroyEventRecords()
        {
            if (m_viewEventRecords != null)
            {
                m_viewEventRecords.Destroy();
                GetFrameworkModule<ObjectPoolM>().Free(m_viewEventRecords);
                m_viewEventRecords = null;
            }
        }
    }
}
