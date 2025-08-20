

namespace NFramework.Module.UIModule
{
    public partial class View
    {
        private IUIFacadeProvider m_NothingProvider;
        public IUIFacadeProvider NothingProvider
        {
            get
            {
                if (m_NothingProvider == null)
                {
                    this.m_NothingProvider = new UIFacadeProviderDynamic(this.ResLoadRecords);
                }
                return m_NothingProvider;
            }
        }

        private IUIFacadeProvider m_DynamicProvider;
        public IUIFacadeProvider DynamicProvider
        {
            get
            {
                if (m_DynamicProvider == null)
                {
                    this.m_DynamicProvider = new UIFacadeProviderDynamic(this.ResLoadRecords);
                }
                return m_DynamicProvider;
            }
        }


        public void DestroyFacadeProvider()
        {
            if (m_NothingProvider != null)
            {
                this.m_NothingProvider.Destroy();
                this.m_NothingProvider = null;
            }
            if (m_DynamicProvider != null)
            {
                this.m_DynamicProvider.Destroy();
                this.m_DynamicProvider = null;
            }
        }
    }
}