
using Proto.Promises;

namespace NFramework.Module.UI
{
    /// <summary>
    /// 带池的provider
    /// </summary>
    public class UIFacadeProviderPool : IUIFacadeProvider
    {
        public UIFacade Alloc<T>() where T : View
        {
            throw new System.NotImplementedException();
        }

        public Promise<UIFacade> AllocAsync<T>() where T : View
        {
            throw new System.NotImplementedException();
        }

        public Promise<UIFacade> AllocAsync(string inViewID)
        {
            throw new System.NotImplementedException();
        }

        public void Destroy()
        {
        }

        public void Free(UIFacade inUIFacade)
        {
            throw new System.NotImplementedException();
        }
    }
}