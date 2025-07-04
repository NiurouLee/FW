using Proto.Promises;
using NFramework.Module.Res;

namespace NFramework.Module.UI
{
    /// <summary>
    /// uiFacade 提供者
    /// </summary>
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

        public UIFacade Alloc(ViewConfig inConfig)
        {
            return null;
        }

        public Promise<UIFacade> AllocAsync(ViewConfig inConfig)
        {
            return Promise<UIFacade>.Resolved(null);
        }

        public Promise<UIFacade> AllocAsync(string inViewID)
        {
            return Promise<UIFacade>.Resolved(null);
        }

        public void Free(UIFacade inUIFacade)
        {
        }
    }
}
