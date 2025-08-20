using Proto.Promises;
using NFramework.Module.ResModule;

namespace NFramework.Module.UIModule
{
    /// <summary>
    /// uiFacade 提供者
    /// </summary>
    public class UIFacadeProviderDynamic : IUIFacadeProvider
    {
        private IResLoader _resLoader;

        public UIFacadeProviderDynamic(IResLoader inResLoader)
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

        public void Destroy()
        {
            throw new System.NotImplementedException();
        }
    }
}
