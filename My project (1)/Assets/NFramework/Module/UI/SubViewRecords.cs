using NFramework.Core.Collections;
using NFramework.Core.ObjectPool;

namespace NFramework.Module.UIModule
{
    public class SubViewRecords : BaseRecords<View>, IFreeToPool
    {
        private View m_orderView;

        public void FreeToPool()
        {
        }

        public void SetView(View inOrder)
        {
            m_orderView = inOrder;
        }

        protected override void OnDestroy()
        {
            foreach (var view in this.Records)
            {
                view.Destroy();
            }
        }
    }
}