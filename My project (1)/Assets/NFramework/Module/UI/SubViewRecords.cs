using NFramework.Core.Collections;

namespace NFramework.Module.UI
{
    public class SubViewRecords : BaseRecords<View>
    {
        private View m_orderView;

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