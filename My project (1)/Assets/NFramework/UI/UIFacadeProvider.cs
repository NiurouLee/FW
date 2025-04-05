using Proto.Promises;

namespace NFramework.UI
{
    public class UIFacadeProviderAssetLoader : IUIFacadeProvider
    {
        private IResLoader _resLoader;

        public UIFacadeProviderAssetLoader(IResLoader inResLoader)
        {
            _resLoader = inResLoader;
        }

        public UIFacade Alloc<T>() where T : View
        {
            return null;
        }

        public Promise<UIFacade> AllocAsync<T>() where T : View
        {
            return Promise<UIFacade>.Resolved(null);
        }

        public void Free(UIFacade inUIFacade)
        {
        }
    }
}
