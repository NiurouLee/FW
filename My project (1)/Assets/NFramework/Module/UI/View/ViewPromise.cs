using NFramework.Core.ObjectPool;

namespace NFramework.Module.UI
{
    public partial class View
    {
        private PromiseRecords m_promiseRecords;
        protected PromiseRecords PromiseRecords
        {
            get
            {
                if (m_promiseRecords == null)
                {
                    m_promiseRecords = ObjectPool.Alloc<PromiseRecords>();
                    m_promiseRecords.Awake();
                }
                return m_promiseRecords;
            }
        }


        private void DestroyPromise()
        {
            if (m_promiseRecords != null)
            {
                m_promiseRecords.Destroy();
            }
        }
    }
}
